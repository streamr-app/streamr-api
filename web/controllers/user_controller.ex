defmodule Streamr.UserController do
  use Streamr.Web, :controller

  alias Guardian.Plug
  alias Streamr.{
    User, RefreshToken, Repo, Mailer, Email, UserSubscription, UploadSupervisor, InitialCreator,
    ProfilePictureUploader
  }

  plug Streamr.Authenticate
    when action in [:me, :my_subscribers, :my_subscriptions, :subscribe, :unsubscribe, :update]

  plug :halt_if_subscribed when action in [:subscribe]
  plug :halt_if_unsubscribed when action in [:unsubscribe]

  def create(conn, %{"user" => user_params}) do
    changeset = User.registration_changeset(%User{}, user_params)

    case Repo.insert(changeset) do
      {:ok, user} ->
        register_new_user(user)

        conn
        |> put_status(201)
        |> render("show.json-api", data: user)

      {:error, changeset} ->
        conn
        |> put_status(422)
        |> render("errors.json-api", data: changeset)
    end
  end

  def show(conn, %{"id" => user_id}) do
    render conn, "show.json-api", data: Repo.get!(User, user_id)
  end

  def auth(conn, %{"username" => email, "password" => password, "grant_type" => "password"}) do
    case User.find_and_confirm_password(email, password) do
      {:ok, user} ->
        {new_conn, jwt} = generate_access_token(conn, user)
        {:ok, refresh_token} = RefreshToken.create_for_user(user)

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

  def me(conn, _params) do
    render(conn, "show.json-api", data: Plug.current_resource(conn))
  end

  def update(conn, %{"user" => user_params}) do
    changeset = update_changeset(conn.assigns.current_user, user_params)

    case Repo.update(changeset) do
      {:ok, user} -> render(conn, "show.json-api", data: user)
      {:error, errors} -> conn |> put_status(422) |> render("errors.json-api", data: errors)
    end
  end

  def my_subscriptions(conn, params) do
    subscriptions = conn.assigns.current_user |> User.subscriptions_for() |> Repo.paginate(params)

    render(conn, "index.json-api", data: subscriptions)
  end

  def my_subscribers(conn, params) do
    subscribers = conn.assigns.current_user |> User.subscribed_to() |> Repo.paginate(params)

    render(conn, "index.json-api", data: subscribers)
  end

  def subscribe(conn, %{"user_id" => subscription_id}) do
    changeset = UserSubscription.new_subscription_changeset(
      %UserSubscription{},
      %{subscription_id: subscription_id, subscriber_id: conn.assigns.current_user.id}
    )

    case Repo.insert(changeset) do
      {:ok, _} -> send_resp(conn, 204, "")
      {:error, error} -> render(conn, "errors.json-api", data: error)
    end
  end

  def unsubscribe(conn, %{"user_id" => subscription_id}) do
    subscription = Repo.get_by!(
      UserSubscription,
      subscription_id: subscription_id,
      subscriber_id: conn.assigns.current_user.id
    )

    case Repo.delete(subscription) do
      {:ok, _} -> send_resp(conn, 204, "")
      {:error, error} -> conn |> put_status(400) |> render("errors.json-api", data: error)
    end
  end

  def register_new_user(user) do
    Supervisor.start_child UploadSupervisor, fn ->
      InitialCreator.process(user)
      send_welcome_email(user)
    end
  end

  defp halt_if_subscribed(conn, _) do
    if get_subscription(conn) do
      conn |> send_resp(204, "") |> halt
    else
      conn
    end
  end

  defp halt_if_unsubscribed(conn, _) do
    if get_subscription(conn) do
      conn
    else
      conn |> send_resp(204, "") |> halt
    end
  end

  def get_subscription(conn) do
    Repo.get_by(
      UserSubscription,
      subscription_id: conn.params["user_id"],
      subscriber_id: conn.assigns.current_user.id
    )
  end

  defp generate_access_token(conn, user) do
    new_conn = Plug.api_sign_in(conn, user)
    jwt = Plug.current_token(new_conn)

    {new_conn, jwt}
  end

  defp send_welcome_email(user) do
    user
    |> Email.welcome
    |> Mailer.deliver
  end

  defp update_changeset(user, params) do
    user
    |> User.changeset(params)
    |> password_changeset(params)
    |> image_changeset(user, params)
  end

  defp password_changeset(changeset, params) do
    if Map.get(params, "password") do
      User.registration_changeset(changeset, params)
    else
      changeset
    end
  end

  defp image_changeset(changeset, user, params) do
    if Map.get(params, "image") do
      params["image"]
      |> ProfilePictureUploader.upload(user)
      |> User.image_key_changeset(changeset)
    else
      changeset
    end
  end
end
