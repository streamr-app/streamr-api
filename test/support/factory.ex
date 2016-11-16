defmodule Streamr.Factory do
  # with Ecto
  use ExMachina.Ecto, repo: Streamr.Repo

  def user_factory do
    %Streamr.User{
      name: sequence(:username, &"User-#{&1}"),
      email: sequence(:email, &"example#{&1}@example.com"),
      password: "password"
    }
  end
end
