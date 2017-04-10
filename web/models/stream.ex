defmodule Streamr.Stream do
  use Streamr.Web, :model
  use Timex.Ecto.Timestamps
  use Streamr.Voteable
  alias Streamr.{Repo, UserSubscription}
  import Ecto.Query

  schema "streams" do
    field :title, :string, null: false
    field :description, :string
    field :image, :string
    field :s3_key, :string
    field :duration, :integer
    field :published_at, Timex.Ecto.DateTime
    field :votes_count, :integer, null: false, default: 0

    belongs_to :user, Streamr.User
    belongs_to :topic, Streamr.Topic
    has_one :stream_data, Streamr.StreamData, on_delete: :delete_all
    has_many :comment, Streamr.Comment, on_delete: :delete_all

    timestamps()
  end

  def changeset(model, params \\ %{}) do
    model
    |> cast(params, [:title, :description])
    |> validate_required([:title])
  end

  def duration_changeset(model) do
    published_at = Timex.now()
    duration = Timex.to_unix(published_at) - Timex.to_unix(model.inserted_at)

    model
    |> cast(%{duration: duration, published_at: published_at}, [:duration, :published_at])
  end

  def with_associations(query) do
    from stream in query,
    preload: [:user, :topic],
    select: stream
  end

  def ordered(query) do
    from stream in query,
    order_by: [desc: stream.published_at]
  end

  def for_user(user_id) do
    from stream in Streamr.Stream,
    where: stream.user_id == ^user_id
  end

  def for_topic(topic_id) do
    from stream in Streamr.Stream,
    where: stream.topic_id == ^topic_id
  end

  def subscribed(user) do
    from stream in Streamr.Stream,
    inner_join: sub in UserSubscription, on: sub.subscriber_id == ^user.id,
    where: stream.user_id == sub.subscription_id
  end

  def store_s3_key(stream, s3_key) do
    params = %{s3_key: s3_key}

    stream
    |> cast(params, [:s3_key])
    |> validate_required([:s3_key])
    |> Repo.update
  end
end
