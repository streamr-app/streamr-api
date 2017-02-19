use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :streamr, Streamr.Endpoint,
  http: [port: 4001],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Configured for Mail T
config :streamr, Streamr.Mailer,
  adapter: Swoosh.Adapters.Test

# Configure your database
config :streamr, Streamr.Repo,
  adapter: Ecto.Adapters.Postgres,
  database: "streamr_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox
