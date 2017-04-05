defmodule Streamr.UserSubscription do
  use Streamr.Web, :model

  schema "user_subscriptions" do
    belongs_to :subscriber, Streamr.User, foreign_key: :subscriber_id
    belongs_to :subscription, Streamr.User, foreign_key: :subscription_id

    timestamps()
  end

  def new_subscription_changeset(subscription, params) do
    subscription
    |> cast(params, [:subscription_id, :subscriber_id])
  end
end
