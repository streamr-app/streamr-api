defmodule Streamr.StreamController do
  use Streamr.Web, :controller
  alias Streamr.{Stream, Repo}

  def index(conn, params) do
    streams = Stream
    |> Stream.with_users
    |> Stream.ordered
    |> Repo.paginate(params)

    render(conn, "index.json-api", data: streams)
  end
end
