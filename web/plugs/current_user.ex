defmodule Streamr.CurrentUser do
  alias Plug.Conn
  alias Guardian.Plug

  def init(opts), do: opts

  def call(conn, _opts) do
    current_user = Plug.current_resource(conn)
    Conn.assign(conn, :current_user, current_user)
  end
end
