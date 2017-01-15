defmodule Streamr.AuthHandler do
  use Streamr.Web, :controller

  def unauthenticated(conn, _params) do
    conn
    |> put_status(401)
    |> render(Streamr.AuthView, "unauthenticated.json")
  end
end
