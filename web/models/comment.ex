defmodule Streamr.Comment do
  use Streamr.Web, :model
  use Timex.Ecto.Timestamps
  alias Streamr.Repo
  import Ecto.Query

  schema "comments" do
    belongs_to :stream, Streamr.Stream
    belongs_to :user, Streamr.User
    field :body, :string, null: false

    timestamps()
  end

  def changeset(model, params \\ :empty) do
    model
    |> cast(params, [:body])
    |> validate_required([:body])
  end

  def with_users(query) do
    from comment in query,
    preload: [:user],
    select: comment
  end

  def ordered(query) do
    from comment in query,
    order_by: [desc: comment.inserted_at]
  end

  def for_stream(stream_id) do
    from comment in Streamr.Comment,
    where: comment.stream_id == ^stream_id
  end
end
