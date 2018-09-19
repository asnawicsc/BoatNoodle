use Mix.Config

# For development, we disable any cache and enable
# debugging and code reloading.
#
# The watchers configuration can be used to run external
# watchers to your application. For example, we use it
# with brunch.io to recompile .js and .css sources.
config :boat_noodle, BoatNoodleWeb.Endpoint,
  http: [port: 40003],
  debug_errors: true,
  code_reloader: true,
  check_origin: false,
  watchers: []

# ## SSL Support
#
# In order to use HTTPS in development, a self-signed
# certificate can be generated by running the following
# command from your terminal:
#
#     openssl req -new -newkey rsa:4096 -days 365 -nodes -x509 -subj "/C=US/ST=Denial/L=Springfield/O=Dis/CN=www.example.com" -keyout priv/server.key -out priv/server.pem
#
# The `http:` config above can be replaced with:
#
#     https: [port: 4000, keyfile: "priv/server.key", certfile: "priv/server.pem"],
#
# If desired, both `http:` and `https:` keys can be
# configured to run both http and https servers on
# different ports.

# Watch static and templates for browser reloading.
config :boat_noodle, BoatNoodleWeb.Endpoint,
  live_reload: [
    patterns: [
      ~r{priv/static/.*(js|css|png|jpeg|jpg|gif|svg)$},
      ~r{priv/gettext/.*(po)$},
      ~r{lib/boat_noodle_web/views/.*(ex)$},
      ~r{lib/boat_noodle_web/templates/.*(eex)$}
    ]
  ]

# Do not include metadata nor timestamps in development logs
config :logger, :console, format: "[$level] $message\n"

# Set a higher stacktrace during development. Avoid configuring such
# in production as building large stacktraces may be expensive.
config :phoenix, :stacktrace_depth, 20

# Configure your database
# config :boat_noodle, BoatNoodle.Repo,
#   adapter: Ecto.Adapters.Postgres,
#   username: "postgres",
#   password: "postgres",
#   database: "boat_noodle_dev",
#   hostname: "localhost",
#   pool_size: 10

config :boat_noodle, BoatNoodle.RepoGeop,
  adapter: Ecto.Adapters.MySQL,
  hostname: "pos.geopbyteapp.com",
  port: "3306",
  username: "posgb_user",
  password: "!@#000",
  database: "posgb_boatnoodle",
  pool_size: 10,
  timeout: 1500_000

# config :boat_noodle, BoatNoodle.RepoGeop,
#   adapter: Ecto.Adapters.MySQL,
#   hostname: "110.4.42.47",
#   port: "15100",
#   username: "phoenix_bn",
#   password: "123123",
#   database: "chillchi_db",
#   pool_size: 10,
#   timeout: 1500_000

config :boat_noodle, BoatNoodle.Repo,
  adapter: Ecto.Adapters.MySQL,
  hostname: "110.4.42.47",
  port: "15100",
  username: "phoenix_bn",
  password: "123123",
  database: "posgb_boatnoodle",
  pool_size: 200,
  timeout: 1500_000

# @doc """
# # regarding consolidating databases, im wondering should i wrtie another function that will interact
# with other databases and initiate the migration process...

# 1. set the default databases
# 2. ensure the columns already set in the default database
# 3. individual databases will be imported...

# should i include a a timestamp? for fallback purpose....

# """
