# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :boat_noodle,
  ecto_repos: [BoatNoodle.Repo]

# Configures the endpoint
config :boat_noodle, BoatNoodleWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "DYMS+BAX/beJI31z9VqOJBg04C8fYM4KjD1iD5j8As6qoSDAWIkWNhkR7D9isPiN",
  render_errors: [view: BoatNoodleWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: BoatNoodle.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:user_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
