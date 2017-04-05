defmodule Streamr.UserControllerTest do
  use Streamr.ConnCase

  import Streamr.Factory
  import Swoosh.TestAssertions

  describe "POST /users" do
    test "with valid user data", %{conn: conn} do
      valid_user = :user |> params_for() |> with_password()

      conn = post conn, "api/v1/users", %{"user" => valid_user}
      body = json_response(conn, 201)

      assert body["data"]["id"]
      assert body["data"]["attributes"]["email"] == valid_user.email
      assert body["data"]["attributes"]["name"] == valid_user.name
      refute body["data"]["attributes"]["password"]
      refute body["data"]["attributes"]["password_hash"]
    end

    test "with valid user data, sends email for verification", %{conn: conn} do
      valid_user = :user |> params_for() |> with_password()

      post conn, "api/v1/users", %{"user" => valid_user}
      assert_email_sent Streamr.Email.welcome(valid_user)
    end

    test "with invalid data", %{conn: conn} do
      invalid_user = :user |> params_for(email: nil) |> with_password()

      conn = post conn, "api/v1/users", %{"user" => invalid_user}
      body = json_response(conn, 422)["errors"]
      assert body == [%{
        "detail" => "Email can't be blank",
        "title" => "can't be blank",
        "source" => %{"pointer" => "/data/attributes/email"}}]
    end

    test "when a user exists with the email", %{conn: conn} do
      valid_user = :user |> params_for() |> with_password()

      conn = post conn, "api/v1/users", %{"user" => valid_user}
      json_response(conn, 201)

      conn = build_conn()
      conn = post conn, "api/v1/users", %{"user" => valid_user}

      body = json_response(conn, 422)["errors"]
      assert body == [%{
        "detail" => "Email is invalid",
        "title" => "is invalid",
        "source" => %{"pointer" => "/data/attributes/email"}}]
    end
  end

  describe "GET /users/:id" do
    test "get a user's profile" do
      user = insert(:user)

      conn = get(
        build_conn(),
        "/api/v1/users/#{user.id}"
      )

      response = json_response(conn, 200)["data"]

      assert String.to_integer(response["id"]) == user.id
    end

    test "current_user_subscribed is true if the user is subscribed" do
      [me, other] = insert_list(2, :user)
      insert(:user_subscription, subscriber: me, subscription: other)

      conn = get_authorized(me, "/api/v1/users/#{other.id}")
      response = json_response(conn, 200)["data"]

      assert response["attributes"]["current-user-subscribed"]
    end

    test "current_user_subscribed is false if the user is unsubscribed" do
      [me, other] = insert_list(2, :user)

      conn = get_authorized(me, "/api/v1/users/#{other.id}")
      response = json_response(conn, 200)["data"]

      refute response["attributes"]["current-user-subscribed"]
    end
  end

  describe "POST /users/auth (password grant type)" do
    setup do
      user = :user
             |> build()
             |> with_password()
             |> set_password("password")
             |> insert

      {:ok, [user: user]}
    end

    test "with valid credentials", context do
      conn = post(
        build_conn(),
        "api/v1/users/auth",
        %{username: context[:user].email, password: context[:user].password, grant_type: "password"}
      )

      body = json_response(conn, 200)

      assert body["access_token"]
      assert body["expires_in"] == 3600
      assert body["token_type"] == "bearer"
      assert body["refresh_token"]
    end

    test "with invalid credentials" do
      conn = post(
        build_conn(),
        "api/v1/users/auth",
        %{username: "foo@bar.com", password: "INVALID PASSWORD", grant_type: "password"}
      )

      body = json_response(conn, 401)["errors"]

      assert body == [%{
          "detail" => "Invalid username/password combination",
          "title" => "invalid login",
          "status" => 401
        }]
    end
  end

  describe "POST /users/auth (refresh_token grant type)" do
    test "with a valid refresh token" do
      user = insert(:user)
      refresh_token = insert(:refresh_token, user: user)

      conn = post(
        build_conn(),
        "api/v1/users/auth",
        %{refresh_token: refresh_token.token, grant_type: "refresh_token"}
      )

      body = json_response(conn, 200)

      assert body["access_token"]
      assert body["expires_in"] == 3600
      assert body["token_type"] == "bearer"
    end

    test "with an invalid refresh token" do
      conn = post(
        build_conn(),
        "api/v1/users/auth",
        %{refresh_token: "INVALID", grant_type: "refresh_token"}
      )

      body = json_response(conn, 401)["errors"]

      assert body == [%{
          "detail" => "Invalid refresh token",
          "title" => "invalid token",
          "status" => 401
        }]
    end
  end

  describe "GET /api/v1/users/email_available" do
    test "when the email has already been taken by another user" do
      user = insert(:user)

      conn = get(
        build_conn(),
        "api/v1/users/email_available",
        %{email: user.email}
      )

      assert %{"email_available" => false} == json_response(conn, 200)
    end

    test "when the email has not been taken by another user" do
      conn = get(
        build_conn(),
        "api/v1/users/email_available",
        %{email: "new-email@example.com"}
      )

      assert %{"email_available" => true} == json_response(conn, 200)
    end
  end

  describe "GET /api/v1/users/me" do
    test "when the user is authenticated" do
      user = insert(:user)
      conn = build_conn()
             |> Guardian.Plug.api_sign_in(user)
             |> get("/api/v1/users/me")

      body = json_response(conn, 200)["data"]

      assert body["id"] == Integer.to_string(user.id)
      assert body["attributes"]["email"] == user.email
      assert body["attributes"]["name"] == user.name
    end

    test "when there is no authentication" do
      conn = build_conn() |> get("/api/v1/users/me")

      json_response(conn, 401)
    end
  end

  describe "GET /api/v1/users/my_subscriptions" do
    test "returns users I subscribe to" do
      me = insert(:user)
      subscriptions = insert_list(3, :user_subscription, subscriber: me)
      _others = insert_list(2, :user_subscription, subscriber: insert(:user))

      conn = get_authorized(me, "/api/v1/users/my_subscriptions")

      response = json_response(conn, 200)["data"]
      assert Enum.count(response) == Enum.count(subscriptions)
    end

    test "my subscriptions show that I am subscribed" do
      me = insert(:user)
      insert_list(3, :user_subscription, subscriber: me)

      conn = get_authorized(me, "/api/v1/users/my_subscriptions")

      response = json_response(conn, 200)["data"]
      assert Enum.all?(response, &(&1["attributes"]["current-user-subscribed"]))
    end

    test "fails without an auth token" do
      conn = get(build_conn(), "/api/v1/users/my_subscriptions")

      json_response(conn, 401)
    end
  end

  describe "GET /api/v1/users/my_subscribers" do
    test "returns all users subscribed to me" do
      me = insert(:user)
      subscribers = insert_list(3, :user_subscription, subscription: me)
      _others = insert_list(2, :user_subscription, subscription: insert(:user))

      conn = get_authorized(me, "/api/v1/users/my_subscribers")

      response = json_response(conn, 200)["data"]
      assert Enum.count(response) == Enum.count(subscribers)
    end

    test "fails without an auth token" do
      conn = get(build_conn(), "/api/v1/users/my_subscribers")

      json_response(conn, 401)
    end
  end

  describe "POST /api/v1/users/:id/subscribe" do
    test "it subscribes the current user to the specified user" do
      [me, other] = insert_list(2, :user)

      conn = post_authorized(me, "/api/v1/users/#{other.id}/subscribe")

      assert conn.status == 204
      assert [other] == Repo.preload(me, :subscriptions).subscriptions
    end

    test "it returns a 204 when the user is already subscribed" do
      [me, other] = insert_list(2, :user)

      conn = post_authorized(me, "/api/v1/users/#{other.id}/subscribe")

      assert conn.status == 204
    end

    test "it prevents subscribing unless the user is logged in" do
      user = insert(:user)
      conn = post(build_conn(), "/api/v1/users/#{user.id}/subscribe")

      json_response(conn, 401)
    end
  end

  describe "POST /api/v1/users/:id/unsubscribe" do
    test "it unsubscribes the current user to the specified user" do
      [me, other] = insert_list(2, :user)
      insert(:user_subscription, subscriber: me, subscription: other)

      conn = post_authorized(me, "/api/v1/users/#{other.id}/unsubscribe")

      assert conn.status == 204
      assert [] == Repo.preload(me, :subscriptions).subscriptions
    end

    test "it returns a 204 when the user is not subscribed" do
      [me, other] = insert_list(2, :user)

      conn = post_authorized(me, "/api/v1/users/#{other.id}/unsubscribe")

      assert conn.status == 204
    end

    test "it prevents unsubscribing unless the user is logged in" do
      user = insert(:user)
      conn = post(build_conn(), "/api/v1/users/#{user.id}/unsubscribe")

      json_response(conn, 401)
    end
  end
end
