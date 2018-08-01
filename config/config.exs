# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :phelmx,
  ecto_repos: [Phelmx.Repo]

# Configures the endpoint
config :phelmx, PhelmxWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "AMTOTaiBx7SvgtlTsgpJ6ijjr6rwbTL40J1/x/1SzN/C0SBrn6D98MIDUXw4prOn",
  render_errors: [view: PhelmxWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Phelmx.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:user_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
