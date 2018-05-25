use Mix.Config

config :boat_noodle, BoatNoodleWeb.Endpoint,
  http: [port: 8889],
  url: [host: "110.4.42.45", port: 8889]

config :logger, level: :info

config :boat_noodle, BoatNoodleWeb.Endpoint, server: true

import_config "prod.secret.exs"
