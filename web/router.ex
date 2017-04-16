defmodule Streamr.Router do
  use Streamr.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
    plug Guardian.Plug.VerifyHeader, realm: "Bearer"
    plug Guardian.Plug.LoadResource
    plug Streamr.CurrentUser
  end

  scope "/api/v1", Streamr do
    pipe_through :api

    post "/password_reset", PasswordResetController, :generate
    put "/password_reset", PasswordResetController, :update_password

    post "/users/auth", UserController, :auth
    get "/users/email_available", UserController, :email_available
    get "/users/me", UserController, :me
    put "/users/me", UserController, :update
    get "/users/my_subscriptions", UserController, :my_subscriptions
    get "/users/my_subscribers", UserController, :my_subscribers
    resources "/users", UserController, only: [:create, :show] do
      resources "/streams", StreamController, only: [:index]

      post "/subscribe", UserController, :subscribe
      post "/unsubscribe", UserController, :unsubscribe
    end

    get "/streams/subscribed", StreamController, :subscribed
    get "/streams/trending", StreamController, :trending
    resources "/streams", StreamController do
      resources "/comments", CommentController, only: [:index, :create]
      post "/my_vote", VoteController, :create
      delete "/my_vote", VoteController, :delete

      post "/add_line", StreamController, :add_line
      post "/end", StreamController, :end_stream
      post "/publish", StreamController, :publish
    end

    resources "/comments", CommentController, only: [:delete] do
      post "/my_vote", VoteController, :create
      delete "/my_vote", VoteController, :delete
    end

    resources "/topics", TopicController, only: [:index] do
      resources "/streams", StreamController, only: [:index]
    end

    resources "/colors", ColorController, only: [:index]
  end
end
