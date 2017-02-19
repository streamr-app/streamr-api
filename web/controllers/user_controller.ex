defmodule Streamr.UserController do
  use Streamr.Web, :controller
  plug Streamr.Authenticate when action in [:me]
  alias Streamr.{User, RefreshToken, Repo, Mailer, Email}

  def create(conn, %{"user" => user_params}) do
    changeset = User.registration_changeset(%User{}, user_params)

    case Repo.insert(changeset) do
      {:ok, user} ->
        send_welcome_email(user)

        conn
        |> put_status(201)
        |> render("show.json-api", data: user)

      {:error, changeset} ->
        conn
        |> put_status(422)
        |> render("errors.json-api", data: changeset)
    end
  end

  def auth(conn, %{"username" => email, "password" => password, "grant_type" => "password"}) do
    case User.find_and_confirm_password(email, password) do
      {:ok, user} ->
        {new_conn, jwt} = generate_access_token(conn, user)
        {:ok, refresh_token} = Streamr.RefreshToken.create_for_user(user)

        new_conn
        |> render("refresh_token.json", access_token: jwt, refresh_token: refresh_token)

      {:error, _} ->
        conn
        |> put_status(401)
        |> render("invalid_login.json")
    end
  end

  def auth(conn, %{"refresh_token" => refresh_token, "grant_type" => "refresh_token"}) do
    if user = RefreshToken.find_associated_user(refresh_token) do
      {new_conn, jwt} = generate_access_token(conn, user)

      new_conn
      |> render("access_token.json", access_token: jwt)
    else
      conn
      |> put_status(401)
      |> render("invalid_refresh_token.json")
    end
  end

  def email_available(conn, %{"email" => email}) do
    conn
    |> render("email_available.json", email_available: !Repo.get_by(User, email: email))
  end

  def me(conn, _assigns) do
    render(conn, "show.json-api", data: Guardian.Plug.current_resource(conn))
  end

  defp generate_access_token(conn, user) do
    new_conn = Guardian.Plug.api_sign_in(conn, user)
    jwt = Guardian.Plug.current_token(new_conn)

    {new_conn, jwt}
  end

  defp send_welcome_email(user) do
    user
    |> Email.welcome
    |> Mailer.deliver
  end
end
