defmodule Streamr.TopicController do
  use Streamr.Web, :controller
  alias Streamr.{Topic, Repo}

  def index(conn, _params) do
    render(conn, "index.json-api", data: Repo.all(Topic))
  end
end
