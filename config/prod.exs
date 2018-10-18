use Mix.Config

config :boat_noodle, BoatNoodleWeb.Endpoint,
  http: [port: 8889],
  url: [host: "gummypos.resertech.com", port: 8889],
  check_origin: ["https://gummypos.resertech.com"]

# config :boat_noodle, BoatNoodleWeb.Endpoint,
#   http: [port: 8889],
#   url: [host: "110.4.42.48", port: 8889],
#   check_origin: ["http://110.4.42.48:8889"]

config :logger, level: :info

config :boat_noodle, BoatNoodleWeb.Endpoint, server: true

# import_config "prod.secret.exs"
config :boat_noodle, BoatNoodle.Repo,
  adapter: Ecto.Adapters.MySQL,
  hostname: "110.4.42.47",
  port: "15100",
  username: "phoenix_bn",
  password: "123123",
  database: "posgb_boatnoodle",
  pool_size: 10,
  timeout: 90000

config :boat_noodle, BoatNoodle.RepoGeop,
  adapter: Ecto.Adapters.MySQL,
  hostname: "chillchill.geopbyteapp.com",
  port: "3306",
  username: "chillchi_user",
  password: "!@#000",
  database: "chillchi_db",
  pool_size: 10,
  timeout: 1500_000
