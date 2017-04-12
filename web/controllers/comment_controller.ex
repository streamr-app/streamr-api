defmodule Streamr.CommentController do
  use Streamr.Web, :controller

  alias Streamr.{Comment, Repo}

  plug Streamr.Authenticate when action in [:create, :delete]

  def index(conn, params) do
    comments = params["stream_id"]
               |> Comment.for_stream()
               |> Comment.with_associations()
               |> Comment.ordered()
               |> Repo.paginate(params)

    render(conn, "index.json-api", data: comments)
  end

  def create(conn, %{"stream_id" => stream_id, "comment" => comment_params}) do
    changeset = conn
                |> build_comment(stream_id)
                |> Comment.changeset(comment_params)

    case Repo.insert(changeset) do
      {:ok, comment} ->
        conn
        |> put_status(201)
        |> render("show.json-api", data: Repo.preload(comment, [:user, :votes]))

      {:error, changeset} ->
        conn
        |> put_status(422)
        |> render("errors.json-api", data: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    comment = Repo.get!(Comment, id)
    conn = authorize!(conn, comment)

    case Repo.delete(comment) do
    {:ok, _} ->
      send_resp(conn, 204, "")

    {:error, _} ->
      conn
      |> put_status(400)
      |> render("errors.json-api")
    end
  end

  defp build_comment(conn, stream_id) do
    %Comment{
      stream_id: String.to_integer(stream_id),
      user_id: conn.assigns.current_user.id
    }
  end
end
