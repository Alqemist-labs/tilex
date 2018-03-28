# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

envar = fn name ->
  case List.keyfind(Application.loaded_applications(), :distillery, 0) do
    {_, _, _} -> "${#{name}}"
    _ -> System.get_env(name)
  end
end

# General application configuration
config :tilex, ecto_repos: [Tilex.Repo]

# Configures the endpoint
config :tilex, TilexWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "mdTtrt4Y4JrtiTv63NepUe4fs1iSt23VfzKpnXm6mawKl6wN8jEfLfIf2HbyMeKe",
  render_errors: [view: TilexWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Tilex.PubSub, adapter: Phoenix.PubSub.PG2],
  http: [protocol_options: [max_request_line_length: 8192, max_header_value_length: 8192]]

# Provide reasonable default for configuration options
config :tilex, :page_size, 5
config :tilex, :auth_controller, AuthController
config :tilex, :slack_notifier, Tilex.Notifications.Notifiers.Slack
config :tilex, :twitter_notifier, Tilex.Notifications.Notifiers.Twitter
config :tilex, :organization_name, envar.("ORGANIZATION_NAME")
config :tilex, :canonical_domain, envar.("CANONICAL_DOMAIN")
config :tilex, :default_twitter_handle, envar.("DEFAULT_TWITTER_HANDLE")
config :tilex, :cors_origin, envar.("CORS_ORIGIN")
config :tilex, :hosted_domain, envar.("HOSTED_DOMAIN")
config :tilex, :guest_author_whitelist, envar.("GUEST_AUTHOR_WHITELIST")

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :ueberauth, Ueberauth,
  providers: [
    google:
      {Ueberauth.Strategy.Google,
       [
         approval_prompt: "force",
         access_type: "offline",
         default_scope: "email profile"
       ]}
  ]

config :ueberauth, Ueberauth.Strategy.Google.OAuth,
  client_id: envar.("GOOGLE_CLIENT_ID"),
  client_secret: envar.("GOOGLE_CLIENT_SECRET")

config :guardian, Guardian,
  allowed_algos: ["HS512"],
  verify_module: Guardian.JWT,
  issuer: "MyApp",
  ttl: {30, :days},
  allowed_drift: 2000,
  verify_issuer: true,
  secret_key: %{
    "k" => "_AbBL082GKlPjoY9o-KM78PhyALavJRtZXOW7D-ZyqE",
    "kty" => "oct"
  },
  serializer: Tilex.GuardianSerializer

config :extwitter, :oauth,
  consumer_key: System.get_env("twitter_consumer_key"),
  consumer_secret: System.get_env("twitter_consumer_secret"),
  access_token: System.get_env("twitter_access_token"),
  access_token_secret: System.get_env("twitter_access_token_secret")

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
