defmodule Streamr.StreamController do
  use Streamr.Web, :controller
  alias Streamr.{Stream, Repo, StreamData, StreamUploader, PreviewUploader}

  plug Streamr.Authenticate when action in [:create, :add_line, :subscribed, :end_stream, :publish]

  def index(conn, params) do
    streams = params
              |> streams_by_parent()
              |> Stream.published()
              |> search_and_order(params)
              |> Stream.with_associations()
              |> Repo.paginate(params)

    render(conn, "index.json-api", data: streams)
  end

  def subscribed(conn, params) do
    streams = conn.assigns.current_user
              |> Stream.subscribed()
              |> Stream.published()
              |> search_and_order(params)
              |> Stream.with_associations()
              |> Repo.paginate(params)

    render(conn, "index.json-api", data: streams)
  end

  def create(conn, %{"stream" => stream_params}) do
    changeset = conn.assigns.current_user
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
    changeset = update_changeset(stream, stream_params)
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

  defp search_and_order(query, %{"search" => search}) do
    query |> Stream.search(search) |> Stream.ordered_by_search(search)
  end

  defp search_and_order(query, _params) do
    Stream.ordered(query)
  end

  defp update_changeset(stream, %{"preview_data" => preview_data} = params) do
    image_s3_key = PreviewUploader.upload(stream, preview_data)

    stream
    |> Stream.image_changeset(image_s3_key)
    |> Stream.changeset(params)
  end

  defp update_changeset(stream, params) do
    Stream.changeset(stream, params)
  end

  defp streams_by_parent(%{"user_id" => user_id}), do: Stream.for_user(user_id)
  defp streams_by_parent(%{"topic_id" => topic_id}), do: Stream.for_topic(topic_id)
  defp streams_by_parent(_params), do: Stream
end
