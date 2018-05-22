# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :active_monitoring,
  ecto_repos: [ActiveMonitoring.Repo]

# Path to sox binary for converting audios
config :active_monitoring, :sox,
  bin: System.get_env("SOX_BINARY") || "sox"

# Configures the AIDA backend url
config :active_monitoring, :aida_backend,
  url: System.get_env("AIDA_BACKEND_URL") || ""

# Configures the endpoint
config :active_monitoring, ActiveMonitoring.Endpoint,
  url: [host: "app.activemonitoring.dev"],
  secret_key_base: "wiyeiXpy+EZpMZ74UEr8RwoFoZoJipByrgYTNT99PZjaLu2rg0qIFhYFw9vTlJsY",
  render_errors: [view: ActiveMonitoring.ErrorView, accepts: ~w(html json)],
  pubsub: [name: ActiveMonitoring.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# %% Coherence Configuration %%   Don't remove this line
config :coherence,
  user_schema: ActiveMonitoring.User,
  repo: ActiveMonitoring.Repo,
  module: ActiveMonitoring,
  logged_out_url: "/",
  email_from_name: "Your Name",
  email_from_email: "yourname@example.com",
  opts: [:trackable, :rememberable]

config :coherence, ActiveMonitoring.Coherence.Mailer,
  adapter: Swoosh.Adapters.Local
# %% End Coherence Configuration %%

config :active_monitoring, ActiveMonitoring.Mailer,
  adapter: Swoosh.Adapters.Local

# Encode JSON properties as camelCase before sending
config :phoenix, :format_encoders,
  json: ProperCase.JSONEncoder.CamelCase

config :active_monitoring, :channel,
  providers: %{
    "nuntium" => ActiveMonitoring.Runtime.NuntiumChannel,
    "verboice" => ActiveMonitoring.Runtime.VerboiceChannel
  }

config :active_monitoring, :verboice,
  base_url: System.get_env("VERBOICE_BASE_URL") || "",
  guisso: [
    base_url: System.get_env("VERBOICE_GUISSO_BASE_URL") || "",
    client_id: System.get_env("VERBOICE_CLIENT_ID") || "",
    client_secret: System.get_env("VERBOICE_CLIENT_SECRET") || "",
    app_id: System.get_env("VERBOICE_APP_ID") || ""
  ]

config :active_monitoring, :guisso,
  base_url: "#{System.get_env("GUISSO_BASE_URL")}",
  auth_url: "#{System.get_env("GUISSO_BASE_URL")}/oauth2/authorize",
  token_url: "#{System.get_env("GUISSO_BASE_URL")}/oauth2/token",
  redirect_uri: System.get_env("GUISSO_REDIRECT_URI"),
  client_id: System.get_env("GUISSO_CLIENT_ID"),
  client_secret: System.get_env("GUISSO_CLIENT_SECRET")

version = case File.read("VERSION") do
  {:ok, version} -> String.trim(version)
  {:error, :enoent} -> "#{Mix.Project.config[:version]}-#{Mix.env}"
end

config :active_monitoring, :version, version

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"

# Import local file
if File.exists?("#{__DIR__}/local.exs") && Mix.env != :test do
  import_config "local.exs"
end
