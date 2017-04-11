defmodule Streamr.StreamController do
  use Streamr.Web, :controller
  alias Streamr.{Stream, Repo, StreamData, StreamUploader}

  plug Streamr.Authenticate when action in [:create, :add_line, :subscribed, :end_stream, :publish]

  def index(conn, params) do
    streams = params
              |> filtered_streams()
              |> Stream.published()
              |> Stream.with_associations()
              |> Stream.ordered()
              |> Repo.paginate(params)

    render(conn, "index.json-api", data: streams)
  end

  def subscribed(conn, params) do
    streams = conn.assigns[:current_user]
              |> Stream.subscribed()
              |> Stream.published()
              |> Stream.with_associations()
              |> Stream.ordered()
              |> Repo.paginate(params)

    render(conn, "index.json-api", data: streams)
  end

  def create(conn, %{"stream" => stream_params}) do
    changeset = conn
                |> Guardian.Plug.current_resource
                |> Ecto.build_assoc(:streams)
                |> Stream.changeset(stream_params)

    case Repo.insert(changeset) do
      {:ok, stream} ->
        StreamData.initialize_for(stream)

        conn
        |> put_status(201)
        |> render("show.json-api", data: with_associations(stream))

      {:error, changeset} ->
        conn
        |> put_status(422)
        |> render("errors.json-api", data: changeset)
    end
  end

  def show(conn, %{"id" => slug}) do
    stream = Stream
             |> Repo.get_by_slug(slug)
             |> with_associations()

    render conn, "show.json-api", data: stream
  end

  def delete(conn, %{"id" => id}) do
    stream = Repo.get!(Stream, id)
    conn = authorize!(conn, stream)

    case Repo.delete(stream) do
    {:ok, _} ->
      send_resp(conn, 204, "")

    {:error, error} ->
      conn
      |> put_status(400)
      |> render("errors.json-api", data: error)
    end
  end

  def update(conn, %{"id" => id, "stream" => stream_params}) do
    stream = Repo.get!(Stream, id)
    changeset = Stream.changeset(stream, stream_params)
    conn = authorize!(conn, stream)

    case Repo.update(changeset) do
      {:ok, stream} ->
        conn
        |> put_status(200)
        |> render("show.json-api", data: with_associations(stream))

      {:error, changeset} ->
        conn
        |> put_status(422)
        |> render("errors.json-api", data: changeset)
    end
  end

  def add_line(conn, params) do
    stream = get_stream(params)
    conn = authorize!(conn, stream)

    case StreamData.append_to(stream, params["line"]) do
      {:ok, _} ->
        send_resp(conn, 201, "")
      {:error, _} ->
        send_resp(conn, 422, "")
    end
  end

  def end_stream(conn, params) do
    stream = get_stream(params)
    conn = authorize!(conn, stream)
    changeset = Stream.duration_changeset(stream)

    case Repo.update(changeset) do
      {:ok, stream} ->
        upload_in_background(stream)

        conn
        |> put_status(201)
        |> render("show.json-api", data: with_associations(stream))
      {:error, changeset} ->
        conn
        |> put_status(422)
        |> render("errors.json-api", data: changeset)
    end
  end

  def publish(conn, params) do
    stream = get_stream(params)
    conn = authorize!(conn, stream)
    changeset = Stream.publish_changeset(stream)

    case Repo.update(changeset) do
      {:ok, stream} ->
        conn
        |> render("show.json-api", data: with_associations(stream))

      {:error, errors} ->
        conn
        |> put_status(422)
        |> render("errors.json-api", data: errors)
    end
  end

  defp upload_in_background(stream) do
    Task.Supervisor.start_child Streamr.UploadSupervisor, fn ->
      upload_stream_contents(stream)
    end
  end

  defp upload_stream_contents(stream) do
    stream_s3_key = stream
              |> Repo.preload(:stream_data)
              |> StreamUploader.process

    Stream.store_s3_key(stream, stream_s3_key)
  end

  defp with_associations(stream) do
    Repo.preload(stream, [:user, :topic, :votes])
  end

  defp get_stream(params) do
    Repo.get!(Stream, Map.get(params, "stream_id"))
  end

  defp filtered_streams(%{"user_id" => user_id}), do: Stream.for_user(user_id)
  defp filtered_streams(%{"topic_id" => topic_id}), do: Stream.for_topic(topic_id)
  defp filtered_streams(_params), do: Stream
end
