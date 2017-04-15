defmodule Streamr.PasswordResetEmail do
  use Phoenix.Swoosh, view: Streamr.Email.PasswordResetView, layout: {Streamr.LayoutView, :email}

  alias Streamr.{PasswordResetToken}

  @frontend_password_reset_url System.get_env("FRONTEND_PASSWORD_RESET_URL")

  def reset_password(user) do
    token = PasswordResetToken.generate(user)
    url = @frontend_password_reset_url <> "?token=#{token}"

    new()
    |> to({user.name, user.email})
    |> from({"Team Streamr", "team@streamr.live"})
    |> subject("Streamr Password Reset")
    |> render_body("password_reset.html" , %{name: user.name, url: url})
  end
end
