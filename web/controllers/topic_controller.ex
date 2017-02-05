defmodule Streamr.TopicController do
  use Streamr.Web, :controller
  alias Streamr.{Topic, Repo}

  def index(conn, params) do
    topics = Topic
    |> Topic.ordered
    |> Repo.paginate(params)

    render(conn, "index.json-api", data: topics)
  end
end
