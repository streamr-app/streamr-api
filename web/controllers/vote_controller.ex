defmodule Streamr.VoteController do
  use Streamr.Web, :controller

  alias Streamr.{Vote, VoteManager}

  plug Streamr.Authenticate
  plug :halt_if_voted when action in [:create]
  plug :halt_unless_voted when action in [:delete]

  def create(conn, params) do
    case VoteManager.create(conn.assigns.current_user, params) do
      {:ok, _vote} -> send_resp(conn, 204, "")
      {:error, _, errors, _} ->
        conn
        |> put_status(422)
        |> render("errors.json-api", data: errors)
    end
  end

  def delete(conn, _params) do
    case VoteManager.delete(conn.assigns.current_user, conn.assigns.vote) do
      {:ok, _} -> send_resp(conn, 204, "")
      {:error, _, errors, _} ->
        conn
        |> put_status(422)
        |> render("errors.json-api", data: errors)
    end
  end

  def halt_if_voted(conn, _) do
    if get_vote(conn) do
      conn |> send_resp(204, "") |> halt()
    else
      conn
    end
  end

  def halt_unless_voted(conn, _) do
    vote = conn |> get_vote() |> Repo.preload([:stream, :comment])

    if vote do
      Plug.Conn.assign(conn, :vote, vote)
    else
      conn |> send_resp(204, "") |> halt()
    end
  end

  def get_vote(conn) do
    get_vote(conn.assigns.current_user.id, conn.params)
  end

  def get_vote(user_id, %{"comment_id" => comment_id}) do
    Repo.get_by(Vote, user_id: user_id, comment_id: comment_id)
  end

  def get_vote(user_id, %{"stream_id" => stream_id}) do
    Repo.get_by(Vote, user_id: user_id, stream_id: stream_id)
  end
end
