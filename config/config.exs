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

# Configures the mailer
config :streamr, Streamr.Mailer,
  adapter: Swoosh.Adapters.Mailgun,
  api_key: System.get_env("MAILGUN_API_KEY"),
  domain: "sandboxd11cf256d75a44d0bb0d42d938bae558.mailgun.org"

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :phoenix, :format_encoders,
  "json-api": Poison

config :mime, :types, %{
  "application/vnd.api+json" => ["json-api"]
}

config :guardian, Guardian,
  issuer: "Streamr",
  ttl: { 7, :days },
  secret_key: %{
    "k" => System.get_env("SECRET_KEY_BASE"),
    "kty" => "oct"
  },
  serializer: Streamr.GuardianSerializer

config :ex_aws,
  access_key_id: [{:system, "AWS_ACCESS_KEY_ID"}, {:awscli, "default", 30}, :instance_role],
  secret_access_key: [{:system, "AWS_SECRET_ACCESS_KEY"}, {:awscli, "default", 30}, :instance_role]

config :ex_aws, :s3,
  region: System.get_env("AWS_S3_REGION")

config :streamr, :secret_key_base, System.get_env("SECRET_KEY_BASE")

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
