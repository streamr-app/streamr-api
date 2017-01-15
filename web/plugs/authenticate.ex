defmodule Streamr.Authenticate do
  use Plug.Builder

  plug Guardian.Plug.EnsureAuthenticated, handler: Streamr.AuthHandler
end
