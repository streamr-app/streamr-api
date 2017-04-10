defmodule Streamr.Comment do
  use Streamr.Web, :model
  use Timex.Ecto.Timestamps
  use Streamr.Voteable
  import Ecto.Query

  schema "comments" do
    belongs_to :stream, Streamr.Stream
    belongs_to :user, Streamr.User
    field :body, :string, null: false
    field :votes_count, :integer, null: false, default: 0

    has_many :votes, Streamr.Vote, on_delete: :delete_all

    timestamps()
  end

  def changeset(model, params \\ %{}) do
    model
    |> cast(params, [:body])
    |> validate_required([:body])
  end

  def with_associations(query) do
    from comment in query,
    preload: [:user, :votes],
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
