# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :active_monitoring,
  ecto_repos: [ActiveMonitoring.Repo]

# Configures the endpoint
config :active_monitoring, ActiveMonitoring.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "wiyeiXpy+EZpMZ74UEr8RwoFoZoJipByrgYTNT99PZjaLu2rg0qIFhYFw9vTlJsY",
  render_errors: [view: ActiveMonitoring.ErrorView, accepts: ~w(html json)],
  pubsub: [name: ActiveMonitoring.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"

# %% Coherence Configuration %%   Don't remove this line
config :coherence,
  user_schema: ActiveMonitoring.User,
  repo: ActiveMonitoring.Repo,
  module: ActiveMonitoring,
  logged_out_url: "/",
  email_from_name: "Your Name",
  email_from_email: "yourname@example.com",
  opts: [:authenticatable, :recoverable, :lockable, :trackable, :unlockable_with_token, :invitable, :registerable, :confirmable, :rememberable]

config :coherence, ActiveMonitoring.Coherence.Mailer,
  adapter: Swoosh.Adapters.Local
# %% End Coherence Configuration %%
