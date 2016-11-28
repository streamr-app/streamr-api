defmodule Streamr.UserTest do
  use Streamr.ConnCase
  alias Streamr.User

  import Streamr.Factory

  describe ".find_and_confirm_password" do
    test "returns the user, if credentials are valid" do
      user = :user
             |> build(password: nil)
             |> set_password("password")
             |> insert

      assert {:ok, user} == User.find_and_confirm_password(user.email, "password")
    end

    test "returns nil if credentials are invalid" do
      {:error, user} = User.find_and_confirm_password("invalid email", "invalid password")

      refute user
    end
  end
end
