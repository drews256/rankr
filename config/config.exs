# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :budgco,
  ecto_repos: [Budgco.Repo]

# Configures the endpoint
config :budgco, BudgcoWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "xI0Cy73Ou5YeSSunAiqoXL8KbSpza/gf0B0Ue4UWCqST26bnbvKPCLh0TkXClOE+",
  render_errors: [view: BudgcoWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: Budgco.PubSub,
  live_view: [signing_salt: "84IDpi3P"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :ueberauth, Ueberauth,
  providers: [
    facebook:
      {Ueberauth.Strategy.Facebook,
       [
         profile_fields: "name,email,first_name,last_name",
         display: "popup"
       ]},
    google: {Ueberauth.Strategy.Google, [opt1: "value", opts2: "value"]}
  ]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
