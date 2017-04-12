defmodule Streamr.TopicController do
  use Streamr.Web, :controller
  alias Streamr.{Topic, Repo}

  def index(conn, _params) do
    topics = Topic |> Topic.ordered |> Repo.all()

    render(conn, "index.json-api", data: topics)
  end
end
