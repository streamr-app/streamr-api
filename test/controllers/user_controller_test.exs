defmodule Streamr.UserControllerTest do
  use Streamr.ConnCase

  @valid_user_attrs %{name: "Foo Bar", email: "foo@bar.com", password: "password"}
  @invalid_user_attrs %{name: "Foo Bar", email: nil, password: "password"}

  describe "POST /users/new" do
    test "with valid user data", %{conn: conn} do
      conn = post conn, "api/v1/users/new", %{"user" => @valid_user_attrs}
      body = json_response(conn, 201)

      assert body["data"]["id"]
      assert body["data"]["attributes"]["email"] == "foo@bar.com"
      assert body["data"]["attributes"]["name"] == "Foo Bar"
      refute body["data"]["attributes"]["password"]
      refute body["data"]["attributes"]["password_hash"]
    end

    test "with invalid data", %{conn: conn} do
      conn = post conn, "api/v1/users/new", %{"user" => @invalid_user_attrs}
      body = json_response(conn, 422)["errors"]
      assert body == [%{
        "detail" => "Email can't be blank",
        "title" => "can't be blank",
        "source" => %{"pointer" => "/data/attributes/email"}}]
    end

    test "when a user exists with the email", %{conn: conn} do
      conn = post conn, "api/v1/users/new", %{"user" => @valid_user_attrs}
      json_response(conn, 201)

      conn = build_conn()
      conn = post conn, "api/v1/users/new", %{"user" => @valid_user_attrs}

      body = json_response(conn, 422)["errors"]
      assert body == [%{
        "detail" => "Email is invalid",
        "title" => "is invalid",
        "source" => %{"pointer" => "/data/attributes/email"}}]
    end
  end
end
