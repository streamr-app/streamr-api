defmodule Streamr.StreamControllerTest do
  use Streamr.ConnCase

  import Streamr.Factory

  alias Streamr.{Repo, Stream, StreamData}

  describe "GET /api/v1/streams" do
    setup do
      insert_list(2, :stream)

      :ok
    end

    test "it returns all streams" do
      conn = get(
        build_conn(),
        "/api/v1/streams"
      )

      response = json_response(conn, 200)["data"]

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

  describe "POST /api/v1/streams/:id" do
    test "it adds a new line to the stream's stream_data" do
      user = insert(:user)
      stream = :stream |> insert |> with_stream_data
      line_data = build(:line_data)

      conn = post_authorized(user, "/api/v1/streams/#{stream.id}/add_line", %{line: line_data})
      assert response(conn, 201)

      data = StreamData.for_stream(stream)
      assert data.lines == [line_data]
    end
  end
end
