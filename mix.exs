defmodule AOC2018.MixProject do
  use Mix.Project

  def project do
    [
      app: :adventofcode2018,
      version: "0.1.0",
      elixir: "~> 1.7",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      test_paths: ["."],
      test_pattern: "day*.{ex,exs}"
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    []
  end
end
