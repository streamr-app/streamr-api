defmodule Streamr.Stream do
  use Streamr.Web, :model
  use Timex.Ecto.Timestamps
  use Streamr.Voteable
  alias Streamr.{Repo, UserSubscription}
  import Ecto.Query

  @title_similarity_threshold 0.2
  @description_similarity_threshold 0.4

  schema "streams" do
    field :title, :string, null: false
    field :description, :string
    field :image_s3_key, :string
    field :s3_key, :string
    field :audio_s3_key, :string
    field :duration, :integer
    field :published_at, Timex.Ecto.DateTime
    field :votes_count, :integer, null: false, default: 0
    field :image_s3_keys, :map

    belongs_to :user, Streamr.User
    belongs_to :topic, Streamr.Topic
    has_one :stream_data, Streamr.StreamData, on_delete: :delete_all
    has_many :comment, Streamr.Comment, on_delete: :delete_all
    has_many :votes, Streamr.Vote, on_delete: :delete_all

    timestamps()
  end

  def published(query) do
    from stream in query,
    where: not is_nil(stream.published_at)
  end

  def search(query, nil), do: query
  def search(query, search) do
    from stream in query,
    where: fragment("similarity(?, ?) > ?", stream.title, ^search, @title_similarity_threshold),
    or_where: fragment(
      "similarity(?, ?) > ?",
      stream.description,
      ^search,
      @description_similarity_threshold
    )
  end

  def ordered_by_search(query, search) do
    from stream in query,
    order_by: fragment("similarity(?, ?) DESC", stream.title, ^search)
  end

  def trending(query) do
    from stream in query,
    where: stream.votes_count > 0,
    order_by: fragment("""
      (votes_count * log(votes_count + 1) +
        extract(epoch from published_at))
      / 45000 desc
    """)
  end

  def changeset(stream, params \\ %{}) do
    stream
    |> cast(params, [:title, :description, :topic_id, :audio_s3_key, :image_s3_keys])
    |> validate_required([:title])
    |> validate_audio_belongs_to_stream(stream)
  end

  def stream_end_changeset(stream, params) do
    stream
    |> cast(params, [:image_s3_keys, :duration])
  end

  def publish_changeset(stream) do
    stream
    |> cast(%{published_at: Timex.now()}, [:published_at])
  end

  def with_associations(query) do
    from stream in query,
    preload: [:user, :topic, :votes],
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

  defp validate_audio_belongs_to_stream(%{changes: %{audio_s3_key: key}} = changeset, stream) do
    if valid_audio_s3_key?(key, stream) do
      changeset
    else
      invalid_audio_key_error(changeset)
    end
  end

  defp validate_audio_belongs_to_stream(changeset, _stream) do
    changeset
  end

  defp valid_audio_s3_key?(audio_s3_key, stream) do
    audio_s3_key && String.starts_with?(audio_s3_key, "streams/#{stream.id}")
  end

  defp invalid_audio_key_error(changeset) do
    add_error(changeset, :audio_s3_key, "invalid audio_s3_key")
  end
end
