defmodule RequestTimeout.Sup do
  use Supervisor

  def start_link() do
    Supervisor.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def init(_opts) do
    [
      # Children dynamically added
    ]
    |> Supervisor.init(strategy: :one_for_one)
  end
end
