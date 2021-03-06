defmodule Airflow.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Starts a worker by calling: Airflow.Worker.start_link(arg)
      # {Airflow.Reader, "FT2MADQK"}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Airflow.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
