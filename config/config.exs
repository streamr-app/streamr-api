# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :streamr,
  ecto_repos: [Streamr.Repo]

# Configures the endpoint
config :streamr, Streamr.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "pw/QoF1gYYHahj55vgWz2IBCFUEsEDf5JwuF9Yyw/T2nqmtRgpcdkprA8vniGxG4",
  render_errors: [view: Streamr.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Streamr.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"

config :phoenix, :format_encoders,
  "json-api": Poison

config :mime, :types, %{
  "application/vnd.api+json" => ["json-api"]
}

config :guardian, Guardian,
  issuer: "Streamr",
  ttl: { 1, :hours },
  secret_key: %{"k" => "X5uaThfmNGtgdwaYJJjUFA", "kty" => "oct"},
  serializer: Streamr.GuardianSerializer
