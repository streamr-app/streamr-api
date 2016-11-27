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
end
