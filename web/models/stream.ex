defmodule Streamr.Stream do
  use Streamr.Web, :model
  import Ecto.Query


  schema "streams" do
    belongs_to :user, Streamr.User
    field :title, :string, null: false
    field :description, :string
    field :image, :string

    timestamps
  end

  def with_users(query) do
    from stream in query,
    preload: [:user],
    select: stream
  end

  def ordered(query) do
    from stream in query,
    order_by: [asc: stream.id]
  end
end
