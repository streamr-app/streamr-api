defmodule Streamr.PasswordResetController do
  use Streamr.Web, :controller

  alias Streamr.{Repo, User, PasswordResetEmail, Mailer, PasswordResetToken}
  alias Plug.Conn

  plug :verify_token when action in [:update_password]

  def generate(conn, %{"email" => email}) do
    User
    |> Repo.get_by!(email: email)
    |> PasswordResetEmail.reset_password()
    |> Mailer.deliver()

    send_resp(conn, 204, "")
  end

  def update_password(conn, %{"password" => password}) do
    changeset = User.registration_changeset(conn.assigns.current_user, %{password: password})

    case Repo.update(changeset) do
      {:ok, _user} -> send_resp(conn, 204, "")
      {:error, errors} -> conn |> put_status(422) |> render("errors.json-api", data: errors)
    end
  end

  defp verify_token(%{params: %{"token" => token}} = conn, _) do
    case PasswordResetToken.verify(token) do
      {:ok, user} -> Conn.assign(conn, :current_user, user)
      {:error, _error} -> conn |> put_status(401) |> render("invalid_token.json") |> halt()
    end
  end
end
