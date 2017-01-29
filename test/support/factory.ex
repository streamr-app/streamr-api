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

  def refresh_token_factory do
    %Streamr.RefreshToken{
      user: build(:user),
      token: sequence(:token, &"token-#{&1}")
    }
  end

  def stream_factory do
    %Streamr.Stream{
      user: build(:user),
      title: sequence(:title, &"title-#{&1}"),
      description: sequence(:description, &"description-#{&1}")
    }
  end

  def topic_factory do
    %Streamr.Topic{
      name: sequence(:name, &"topic-#{&1}")
    }
  end

  def set_password(user, password) do
    hashed_password = Comeonin.Bcrypt.hashpwsalt(password)
    %{user | password_hash: hashed_password}
  end
end
