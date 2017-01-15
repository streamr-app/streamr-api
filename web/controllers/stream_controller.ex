defmodule Streamr.StreamController do
  use Streamr.Web, :controller
  alias Streamr.{Stream, Repo}

  def index(conn, _params) do
    streams = Stream |> Repo.all |> Repo.preload(:user)

    render(conn, "index.json-api", data: streams)
  end
end
