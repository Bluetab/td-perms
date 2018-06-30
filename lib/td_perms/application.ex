defmodule TdPerms.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    # List all child processes to be supervised
    children = [
      {Redix, [[], [name: :redix]]}
      # Starts a worker by calling: TdPerms.Worker.start_link(arg)
      # {TdPerms.Worker, arg},
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: TdPerms.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
