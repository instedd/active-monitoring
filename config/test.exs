use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :active_monitoring, ActiveMonitoring.Endpoint,
  http: [port: 4001],
  url: [host: "test.example.com", port: 80],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Configure your database
config :active_monitoring, ActiveMonitoring.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "",
  database: "active_monitoring_test",
  hostname: System.get_env("DATABASE_HOST") || "localhost",
  pool: Ecto.Adapters.SQL.Sandbox,
  ownership_timeout: 10 * 60 * 1000

config :active_monitoring, ActiveMonitoring.Mailer,
  adapter: Swoosh.Adapters.Test
