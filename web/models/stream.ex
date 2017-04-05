defmodule Streamr.Stream do
  use Streamr.Web, :model
  use Timex.Ecto.Timestamps
  alias Streamr.{Repo, UserSubscription}
  import Ecto.Query

  schema "streams" do
    field :title, :string, null: false
    field :description, :string
    field :image, :string
    field :data_url, :string
    field :duration, :integer

    belongs_to :user, Streamr.User
    has_one :stream_data, Streamr.StreamData, on_delete: :delete_all
    has_many :comment, Streamr.Comment, on_delete: :delete_all

    timestamps()
  end

  def changeset(model, params \\ :empty) do
    model
    |> cast(params, [:title, :description])
    |> validate_required([:title])
  end

  def duration_changeset(model) do
    duration = Timex.to_unix(Timex.now()) - Timex.to_unix(model.inserted_at)

    model
    |> cast(%{duration: duration}, [:duration])
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

  def subscribed(user) do
    from stream in Streamr.Stream,
    inner_join: sub in UserSubscription, on: sub.subscriber_id == ^user.id,
    where: stream.user_id == sub.subscription_id
  end

  def store_data_url(stream, data_url) do
    params = %{data_url: data_url}

    stream
    |> cast(params, [:data_url])
    |> validate_required([:data_url])
    |> Repo.update
  end
end
