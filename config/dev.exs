use Mix.Config

# For development, we disable any cache and enable
# debugging and code reloading.
#
# The watchers configuration can be used to run external
# watchers to your application. For example, we use it
# with brunch.io to recompile .js and .css sources.
config :active_monitoring, ActiveMonitoring.Endpoint,
  http: [port: System.get_env("HTTP_PORT") || 4000],
  debug_errors: true,
  code_reloader: true,
  check_origin: false

# Watch static and templates for browser reloading.
config :active_monitoring, ActiveMonitoring.Endpoint,
  live_reload: [
    patterns: [
      # ~r{priv/static/.*(js|css|png|jpeg|jpg|gif|svg)$},
      ~r{priv/gettext/.*(po)$},
      ~r{web/views/.*(ex)$},
      ~r{web/templates/.*(eex)$}
    ]
  ]

# Do not include metadata nor timestamps in development logs
config :logger, :console, format: "[$level] $message\n"

# Set a higher stacktrace during development. Avoid configuring such
# in production as building large stacktraces may be expensive.
config :phoenix, :stacktrace_depth, 20

# Configure your database
config :active_monitoring, ActiveMonitoring.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "",
  database: "active_monitoring_dev",
  hostname: System.get_env("DATABASE_HOST") || "localhost",
  pool_size: 10

config :active_monitoring, ActiveMonitoring.Mailer,
  adapter: Swoosh.Adapters.Local

config :coherence,
  email_from_name: "Active Monitoring Dev",
  email_from_email: "myname@domain.com"

config :coherence, ActiveMonitoring.Coherence.Mailer,
  adapter: Swoosh.Adapters.Local
