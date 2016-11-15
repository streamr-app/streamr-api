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
  end

  scope "/api/v1", Streamr do
    pipe_through :api

    post "/users/new", UserController, :create
  end
end
