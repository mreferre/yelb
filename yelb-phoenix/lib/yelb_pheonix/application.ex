defmodule Yelb.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      YelbWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: Yelb.PubSub},
      # Start the Endpoint (http/https)
      YelbWeb.Endpoint,
      # Start a worker by calling: Yelb.Worker.start_link(arg)
      # {Yelb.Worker, arg},
      {Redix,
       host: Application.get_env(:redix, :host, "localhost"),
       port: Application.get_env(:redix, :port, 6379),
       name: :redix}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Yelb.Supervisor]
    link_return = Supervisor.start_link(children, opts)

    # Initialize all the voting to 0, if the key
    # is not exist yet in the database
    Redix.pipeline(:redix, [
      ["HSETNX", "votes", "ihop", 0],
      ["HSETNX", "votes", "chipotle", 0],
      ["HSETNX", "votes", "outback", 0],
      ["HSETNX", "votes", "bucadibeppo", 0]
    ])

    link_return
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    YelbWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
