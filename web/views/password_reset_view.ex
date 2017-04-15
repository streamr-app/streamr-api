defmodule Streamr.PasswordResetView do
  use Streamr.Web, :view

  def render("invalid_token.json", _assigns) do
    %{errors: [%{
        title: "invalid token",
        detail: "Password reset token is invalid",
        status: 401
        }]}
  end
end
