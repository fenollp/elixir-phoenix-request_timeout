defmodule RequestTimeout.Mixfile do
  use Mix.Project

  def project, do:
    [
      app: :request_timeout,
      version: "1.0.0",
      elixir: "~> 1.8",
      deps: deps(),
      aliases: aliases(),
      package: package(),
      description: description(),
      source_url: "http://github.com/fenollp/elixir-phoenix-request_timeout"
    ]

  def application, do:
    [applications: []]

  defp aliases,
    do: [
      compile: ["format", "compile"]
    ]

  defp deps, do:
    [
      {:plug, 1..7 |> Enum.map(&("~> 1.#{&1}")) |> Enum.join(" or ")}
    ]

  defp description, do:
    """
    An elixir plug that kills long running Phoenix controllers before
    they take your node down. A kind of circuit breaker.
    """

  defp package, do:
    [
      files: ~w(lib/request_timeout.ex mix.exs mix.lock README.md LICENSE),
      maintainers: ["Pierre Fenoll"],
      licenses: ["MIT"],
      links: %{"Github" => project() |> Keyword.fetch!(:source_url)}
    ]
end
