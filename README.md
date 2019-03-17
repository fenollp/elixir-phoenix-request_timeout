# [RequestTimeout](https://github.com/fenollp/elixir-phoenix-request_timeout)
[![Build Status](https://travis-ci.com/fenollp/elixir-phoenix-request_timeout.svg?branch=master)](https://travis-ci.com/fenollp/elixir-phoenix-request_timeout)
[![Hex.pm](https://img.shields.io/hexpm/v/request_timeout.svg)](https://hex.pm/packages/request_timeout)


Plug that kills Phoenix controller processes when they run for too long.

To do that, this Plug starts an additional process alongside the one that's handling
the user request and monitors it until it dies normally or it runs out of time.

It also
* closes the Phoenix connection properly after it has sent an error
* kills the process with a customizable message
* logs the killed process' stack trace properly
* can be used with different options on different Phoenix router scopes

## Setting up

In your mix.exs:

```elixir
  defp deps,
    do: [
      # ...
      {:request_timeout, "~> 1.0"}
      # ...
    ]
```

Then add this plug as early as possible in your pipelines:

```elixir
defmodule MyWeb.Router do
  use MyWeb, :router

  pipeline :api do
    plug :accepts, @accepts
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery

    # Remember: :kill exit signal is untrappable
    plug RequestTimeout, after: 500, err: :kill, sup: RequestTimeout.Sup

    # ...
  end

  # ...
end
```

It is recommended you supervise the monitoring processes under a `one_for_all`. You can use the supervisor provided with this library this way:

```elixir
defmodule MyWeb.Supervisor do
  use Supervisor

  def start_link() do
    Supervisor.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def init(_opts) do
    [
      supervisor(MyWeb.Endpoint, []),
      supervisor(RequestTimeout.Sup, []),
      # ...
    ]
    |> Supervisor.init(strategy: :one_for_one)
  end
end
```

## Options

All options come with [defaults listed here](lib/request_timeout.ex#L6)

* `after: <milliseconds>`: time after which the process will be killed
* `code: <5xx>`: the HTTP status code sent when `conn` is `halt`ed
* `content_type: <MIME>`: value of the `Content-Type` header sent on `halt`
* `msg: <some string>`: the HTTP status message sent on `halt`
* `sup: <pid or registered name>`: the `Supervisor` under which monitoring processes will be spawned.
    * Set this to `nil` for no supervision
* `error: <atom>`: the exit signal that will be used when killing the process
