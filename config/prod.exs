use Mix.Config

# config :boat_noodle, BoatNoodleWeb.Endpoint,
#   http: [port: 8889],
#   url: [host: "pos.str8.my", port: 8889],
#   check_origin: ["http://pos.str8.my"]

config :boat_noodle, BoatNoodleWeb.Endpoint,
  url: [host: "pos.str8.my", port: 443],
  http: [port: 8889],
  force_ssl: [hsts: true],
  https: [
    port: 443,
    otp_app: :boat_noodle,
    keyfile: "/etc/letsencrypt/live/str8.my/privkey.pem",
    cacertfile: "/etc/letsencrypt/live/str8.my/fullchain.pem",
    certfile: "/etc/letsencrypt/live/str8.my/cert.pem"
  ],
  check_origin: ["https://pos.str8.my"]

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

# config :boat_noodle, BoatNoodle.RepoGeop,
#   adapter: Ecto.Adapters.MySQL,
#   hostname: "bnsg.geopbyteapp.com",
#   port: "3306",
#   username: "bnsggumm_user",
#   password: "pos!@#000",
#   database: "bnsggumm_db",
#   pool_size: 10,
#   timeout: 1500_000
