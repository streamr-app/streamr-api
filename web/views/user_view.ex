defmodule Streamr.UserView do
  use Streamr.Web, :view
  use JaSerializer.PhoenixView
  alias Streamr.{Repo, User, UserSubscription}

  attributes [:name, :email, :current_user_subscribed, :image_url]

  def current_user_subscribed(_user, %Plug.Conn{assigns: %{current_user: nil}}), do: false
  def current_user_subscribed(user, %Plug.Conn{assigns: %{current_user: current_user}}) do
    if Ecto.assoc_loaded?(current_user.subscriptions) do
      current_user.subscriptions.member?(user)
    else
      !!Repo.get_by(UserSubscription, subscriber_id: current_user.id, subscription_id: user.id)
    end
  end

  def image_url(user, _conn) do
    Streamr.UrlQualifier.cdn_url_for(user.image_s3_key)
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
end
