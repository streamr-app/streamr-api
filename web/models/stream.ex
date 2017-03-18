defmodule Streamr.Stream do
  use Streamr.Web, :model
  alias Streamr.Repo
  import Ecto.Query

  schema "streams" do
    field :title, :string, null: false
    field :description, :string
    field :image, :string
    field :s3_path, :string

    belongs_to :user, Streamr.User
    has_one :stream_data, Streamr.StreamData

    timestamps()
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

  def for_user(user_id) do
    from stream in Streamr.Stream,
      where: stream.user_id == ^user_id
  end

  def store_s3_path(stream, s3_path) do
    params = %{s3_path: s3_path}

    stream
    |> cast(params, [:s3_path])
    |> validate_required([:s3_path])
    |> Repo.update
  end
end
