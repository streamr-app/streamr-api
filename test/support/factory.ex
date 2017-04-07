defmodule Streamr.Factory do
  # with Ecto
  use ExMachina.Ecto, repo: Streamr.Repo

  def user_factory do
    %Streamr.User{
      name: sequence(:username, &"User-#{&1}"),
      email: sequence(:email, &"example#{&1}@example.com"),
    }
  end

  def with_password(user) do
    %{user | password: "password"}
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
      description: sequence(:description, &"description-#{&1}"),
      topic: build(:topic)
    }
  end

  def topic_factory do
    %Streamr.Topic{
      name: sequence(:name, &"topic-#{&1}")
    }
  end

  def with_stream_data(stream) do
    insert(:stream_data, stream: stream)
    stream
  end

  def stream_data_factory do
    %Streamr.StreamData{
      stream: build(:stream),
      lines: []
    }
  end

  def comment_factory do
    %Streamr.Comment{
      body: sequence(:body, &"comment-#{&1}"),
      stream: build(:stream),
      user: build(:user)
    }
  end

  def line_data_factory do
    %{
      "points" => [%{
        "x" => 0.5,
        "y" => 0.5,
        "time" => 1000
      }],
      "color_id" => 1
    }
  end

  def color_factory do
    %Streamr.Color{
      normal: "red",
      deuteranopia: "Foodelooap",
      protanopia: "foobie doo",
      tritanopia: "foobarb pie"
    }
  end

  def user_subscription_factory do
    %Streamr.UserSubscription{
      subscriber: build(:user),
      subscription: build(:user)
    }
  end

  def set_password(user, password) do
    hashed_password = Comeonin.Bcrypt.hashpwsalt(password)
    %{user | password_hash: hashed_password}
  end
end
