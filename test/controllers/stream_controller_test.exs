defmodule Streamr.StreamControllerTest do
  use Streamr.ConnCase

  import Streamr.Factory

  alias Streamr.{Repo, Stream, StreamData}

  describe "GET /api/v1/streams" do
    test "it returns all streams" do
      published_streams = insert_list(3, :stream)
      _unpublished_streams = insert_list(3, :stream, published_at: nil)

      conn = get(build_conn(), "/api/v1/streams")

      response_ids = conn |> json_response(200) |> response_ids()

      assert response_ids == model_ids(published_streams)
    end
  end

  describe "GET /api/v1/topics/:topic_id/streams" do
    test "it returns streams belonging to the specified topic" do
      topic = insert(:topic)

      streams_in_topic = insert_list(3, :stream, topic: topic)
      _decoys = insert_list(2, :stream)

      conn = get(build_conn(), "/api/v1/topics/#{topic.id}/streams")
      response = json_response(conn, 200)["data"]

      stream_ids_in_topic = streams_in_topic |> Enum.map(&(&1.id)) |> Enum.sort
      response_ids = response |> Enum.map(&(String.to_integer(&1["id"]))) |> Enum.sort

      assert stream_ids_in_topic == response_ids
    end
  end

  describe "GET /api/v1/streams/subscribed" do
    setup do
      [me, subscribed_user] = insert_list(2, :user)

      insert(:user_subscription, subscriber: me, subscription: subscribed_user)
      streams = insert_list(3, :stream, user: subscribed_user)
      _decoys = insert_list(2, :stream)

      {:ok, me: me, subscribed_users_streams: streams}
    end

    test "it returns streams from my subscribers", params do
      conn = get_authorized(params.me, "/api/v1/streams/subscribed")

      response = json_response(conn, 200)["data"]

      subscribed_stream_ids = params.subscribed_users_streams |> Enum.map(&(&1.id)) |> Enum.sort
      response_ids = response |> Enum.map(&(String.to_integer(&1["id"]))) |> Enum.sort

      assert subscribed_stream_ids == response_ids
    end

    test "it returns a 401 when the user is not logged in" do
      conn = get(build_conn(), "/api/v1/streams/subscribed")

      json_response(conn, 401)
    end
  end

  describe "GET /users/:id/streams" do
    test "get a user's streams" do
      user = insert(:user)
      insert_list(2, :stream, user: user)
      insert_list(3, :stream)

      conn = get(
        build_conn(),
        "/api/v1/users/#{user.id}/streams"
      )

      response = json_response(conn, 200)["data"]

      # Finds if all user ids are the same through the collection
      assert response
             |> Enum.map(&(&1["relationships"]["user"]["data"]["id"]))
             |> Enum.all?(&(user.id == String.to_integer(&1)))

      assert 2 == Enum.count(response)
    end
  end

  describe "GET /api/v1/streams/:slug" do
    test "it returns stream with id 2" do
      stream  = insert(:stream)
      slug = Slugger.slugify("#{stream.id} #{stream.title}")

      conn = get(
        build_conn(),
        "/api/v1/streams/#{slug}"
      )

      response = json_response(conn, 200)["data"]

      assert String.to_integer(response["id"]) == stream.id
    end
  end

  describe "POST /api/v1/streams" do
    test "it creates a new stream" do
      user = insert(:user)
      valid_stream = params_for(:stream)

      conn = post_authorized(user, "/api/v1/streams", %{stream: valid_stream})
      body = json_response(conn, 201)

      assert body["data"]["id"]
      assert body["data"]["attributes"]["title"] == valid_stream.title
      assert body["data"]["attributes"]["description"] == valid_stream.description
      assert body["data"]["relationships"]["user"]["data"]["id"] == Integer.to_string(user.id)
    end

    test "it initializes an empty data for the stream" do
      user = insert(:user)
      valid_stream = params_for(:stream)

      conn = post_authorized(user, "/api/v1/streams", %{stream: valid_stream})
      body = json_response(conn, 201)

      stream = Repo.get(Stream, body["data"]["id"])
      assert StreamData.for_stream(stream).lines == []
    end
  end

  describe "POST /api/v1/streams/:id/add_line" do
    setup do
      stream = :stream |> insert |> with_stream_data
      line_data = build(:line_data)

      {:ok, stream: stream, line_data: line_data}
    end

    test "it adds a new line to the stream's stream_data",
    %{stream: stream, line_data: line_data} do
      conn = post_authorized(
        stream.user,
        "/api/v1/streams/#{stream.id}/add_line",
        %{line: line_data}
      )

      assert response(conn, 201)

      assert StreamData.for_stream(stream).lines == [line_data]
    end

    test "it prevents adding lines to another user's stream",
    %{stream: stream, line_data: line_data} do
      try do
        post_authorized(insert(:user), "/api/v1/streams/#{stream.id}/add_line", %{line: line_data})
      rescue
        exception in Bodyguard.NotAuthorizedError ->
          assert Plug.Exception.status(exception) == 403
      end
    end
  end

  describe "POST /api/v1/streams/:id/publish" do
    test "it sets the stream's published_at to the current time" do
      stream = insert(:stream)

      conn = post_authorized(stream.user, "/api/v1/streams/#{stream.id}/publish")
      response = json_response(conn, 200)["data"]

      assert response["attributes"]["published-at"]
    end

    test "it allows the stream to show up in the stream index endpoint" do
      stream = insert(:stream)

      post_authorized(stream.user, "/api/v1/streams/#{stream.id}/publish")
      conn = get(build_conn(), "/api/v1/streams")

      response_ids = conn |> json_response(200) |> response_ids()

      assert Enum.member?(response_ids, stream.id)
    end

    test "it prevents publishing another user's streams" do
      stream = insert(:stream)

      try do
        post_authorized(insert(:user), "/api/v1/streams/#{stream.id}/publish")
      rescue
        exception in Bodyguard.NotAuthorizedError ->
          assert Plug.Exception.status(exception) == 403
      end
    end

    test "it requires the user to be signed in" do
      conn = post(build_conn(), "/api/v1/streams/#{insert(:stream).id}/publish")

      assert conn.status == 401
    end
  end

  describe "PUT /api/v1/streams/:id" do
    setup do
      stream = insert(:stream)
      stream_params = params_for(:stream, %{title: "updated", description: "updated"})

      {:ok, stream: stream, stream_params: stream_params}
    end

    test "updates a stream", %{stream: stream, stream_params: stream_params} do
      conn = put_authorized(stream.user, "/api/v1/streams/#{stream.id}", %{stream: stream_params})
      body = json_response(conn, 200)

      assert body["data"]["id"]
      assert body["data"]["attributes"]["title"] == stream_params.title
      assert body["data"]["attributes"]["description"] == stream_params.description
    end

    test "it prevents updating another user's stream",
    %{stream: stream, stream_params: stream_params} do
      try do
        put_authorized(insert(:user), "/api/v1/streams/#{stream.id}", %{stream: stream_params})
      rescue
        exception in Bodyguard.NotAuthorizedError ->
          assert Plug.Exception.status(exception) == 403
      end
    end

    test "it prevents setting audio_s3_key to another stream's audio",
    %{stream: stream, stream_params: stream_params} do
      other_stream = insert(:stream)
      stream_params = %{stream_params | audio_s3_key: "streams/#{other_stream.id}/foo"}

      conn = put_authorized(stream.user, "/api/v1/streams/#{stream.id}", %{stream: stream_params})

      assert conn.status == 422
    end

    test "it prevents setting audio_s3_key to nil" do
      stream = insert(:stream)
      stream_params = params_for(
        :stream,
        title: "updated",
        description: "updated",
        audio_s3_key: "streams/#{stream.id}/foo"
      )

      put_authorized(stream.user, "/api/v1/streams/#{stream.id}", %{stream: stream_params})

      conn = put_authorized(
        stream.user,
        "/api/v1/streams/#{stream.id}",
        %{stream: %{audio_s3_key: nil}}
      )

      assert conn.status == 422
    end
  end

  describe "DELETE /api/v1/streams/:id" do
    setup do
      {:ok, stream: insert(:stream)}
    end

    test "it deletes the stream", %{stream: stream} do
      conn = delete_authorized(stream.user, "/api/v1/streams/#{stream.id}")

      assert conn.status == 204
      refute Repo.get(Stream, stream.id)
      refute Repo.get_by(StreamData, stream_id: stream.id)
    end

    test "it prevents updating another user's stream", %{stream: stream} do
      try do
        delete_authorized(insert(:user), "/api/v1/streams/#{stream.id}")
      rescue
        exception in Bodyguard.NotAuthorizedError ->
          assert Plug.Exception.status(exception) == 403
      end
    end
  end
end
