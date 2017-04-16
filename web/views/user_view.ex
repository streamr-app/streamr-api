defmodule Streamr.UserView do
  use Streamr.Web, :view
  use JaSerializer.PhoenixView
  alias Streamr.{Repo, UserSubscription, UrlQualifier}

  attributes [:name, :email, :current_user_subscribed, :image_url, :color_preference]

  def current_user_subscribed(_subscription, %Plug.Conn{assigns: %{current_user: nil}}), do: false
  def current_user_subscribed(subscription, %Plug.Conn{assigns: %{current_user: current_user}}) do
    if Ecto.assoc_loaded?(current_user.subscriptions) do
      current_user.subscriptions.member?(subscription)
    else
      subscription_present?(current_user.id, subscription.id)
    end
  end

  def image_url(user, _conn) do
    UrlQualifier.cdn_url_for(user.image_s3_key)
  end

  def render("access_token.json", %{access_token: access_token}) do
    %{
      access_token: access_token,
      token_type: "bearer",
      expires_in: 3600
    }
  end

  def render("refresh_token.json", %{access_token: access_token, refresh_token: refresh_token}) do
    %{
      access_token: access_token,
      token_type: "bearer",
      expires_in: 3600,
      refresh_token: refresh_token.token
    }
  end

  def render("invalid_login.json", _assigns) do
    %{errors: [%{
        title: "invalid login",
        detail: "Invalid username/password combination",
        status: 401}]}
  end

  def render("invalid_refresh_token.json", _assigns) do
    %{errors: [%{
        title: "invalid token",
        detail: "Invalid refresh token",
        status: 401}]}
  end

  def render("email_available.json", %{email_available: email_available}) do
    %{email_available: email_available}
  end

  defp subscription_present?(subscriber_id, subscription_id) do
    subscription = Repo.get_by(
      UserSubscription,
      subscriber_id: subscriber_id,
      subscription_id: subscription_id
    )

    if subscription, do: true, else: false
  end
end
