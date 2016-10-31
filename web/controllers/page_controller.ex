defmodule Streamr.PageController do
  use Streamr.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
