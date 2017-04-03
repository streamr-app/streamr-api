defmodule Streamr.ColorController do
  use Streamr.Web, :controller
  alias Streamr.{Color, Repo}

  def index(conn, _params) do
    render(conn, "index.json-api", data: Repo.all(Color))
  end
end
