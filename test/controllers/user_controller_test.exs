defmodule Streamr.UserControllerTest do
  use Streamr.ConnCase

  import Streamr.Factory

  describe "POST /users" do
    test "with valid user data", %{conn: conn} do
      valid_user = params_for(:user)

      conn = post conn, "api/v1/users", %{"user" => valid_user}
      body = json_response(conn, 201)

      assert body["data"]["id"]
      assert body["data"]["attributes"]["email"] == valid_user.email
      assert body["data"]["attributes"]["name"] == valid_user.name
      refute body["data"]["attributes"]["password"]
      refute body["data"]["attributes"]["password_hash"]
    end

    test "with invalid data", %{conn: conn} do
      invalid_user = params_for(:user, email: nil)

      conn = post conn, "api/v1/users", %{"user" => invalid_user}
      body = json_response(conn, 422)["errors"]
      assert body == [%{
        "detail" => "Email can't be blank",
        "title" => "can't be blank",
        "source" => %{"pointer" => "/data/attributes/email"}}]
    end

    test "when a user exists with the email", %{conn: conn} do
      valid_user = params_for(:user)

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

  describe "POST /users/auth (password grant type)" do
    setup do
      user = :user
             |> build(password: "password")
             |> set_password("password")
             |> insert

      {:ok, [user: user]}
    end

    test "with valid credentials", context do
      conn = post(
        build_conn(),
        "api/v1/users/auth",
        %{email: context[:user].email, password: context[:user].password, grant_type: "password"}
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
        %{email: "foo@bar.com", password: "INVALID PASSWORD", grant_type: "password"}
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
end
