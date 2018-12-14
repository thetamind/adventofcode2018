defmodule AOC.Mixfile do
  use Mix.Project

  def project do
    [
      app: :aoc,
      version: "0.0.1",
      deps: [
        {:dialyxir, "~> 1.0.0-rc.4", only: [:dev], runtime: false}
      ],
      dialyzer: [
        flags: ["-Wunmatched_returns", :error_handling, :race_conditions, :underspecs],
        plt_add_deps: :apps_direct,
        plt_add_apps: []
      ]
    ]
  end
end
