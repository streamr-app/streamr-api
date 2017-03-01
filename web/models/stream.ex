defmodule Streamr.Stream do
  use Streamr.Web, :model
  import Ecto.Query

  schema "streams" do
    field :title, :string, null: false
    field :description, :string
    field :image, :string

    belongs_to :user, Streamr.User
    has_one :stream_data, Streamr.StreamData

    timestamps
  end

  def changeset(model, params \\ :empty) do
    model
    |> cast(params, [:title, :description])
    |> validate_required([:title])
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
