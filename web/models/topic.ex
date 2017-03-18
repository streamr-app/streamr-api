defmodule Streamr.Topic do
  use Streamr.Web, :model

  schema "topics" do
    field :name, :string

    timestamps()
  end

  def ordered(query) do
    from topic in query,
    order_by: [asc: topic.name]
  end
end
