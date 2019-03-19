defmodule RequestTimeout.Mixfile do
  use Mix.Project

  def project,
    do: [
      app: :request_timeout,
      version: "1.0.1",
      elixir: "~> 1.8",
      deps: deps(),
      aliases: aliases(),
      package: package(),
      description: description(),
      source_url: package()[:links]["Github"]
    ]

  def application, do: [extra_applications: [:logger, :runtime_tools]]

  defp aliases,
    do: [
      compile: ["format", "compile"],
      test: ["format", "test"]
    ]

  defp deps,
    do: [
      {:plug, 1..7 |> Enum.map(&"~> 1.#{&1}") |> Enum.join(" or ")},
      {:ex_doc, "~> 0.14", only: :dev, runtime: false}
    ]

  defp description,
    do: """
    An elixir plug that kills long running Phoenix controllers before
    they take your node down. A kind of circuit breaker.
    """

  defp package,
    do: [
      maintainers: ["Pierre Fenoll"],
      licenses: ["MIT"],
      links: %{"Github" => "http://github.com/fenollp/elixir-phoenix-request_timeout"}
    ]
end
