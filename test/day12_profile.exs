defmodule Day12Profile do
  def profile(generation \\ 500) do
    Day12.answer(puzzle_input(), generation)
  end

  def puzzle_input() do
    File.read!("priv/day12.txt")
  end

  def run({state, rules}, generation) do
    Day12.all_generations(state, rules)
    |> Enum.at(generation)
  end

  def bench(tag \\ nil) do
    inputs = %{
      "puzzle" => puzzle_input() |> Day12.parse()
    }

    jobs = %{
      "500" => fn input -> run(input, 500) end,
      "5_000" => fn input -> run(input, 5_000) end
    }

    options =
      [
        time: 5,
        memory_time: 1,
        inputs: inputs
      ]
      |> Keyword.merge(option_for_tag(tag))

    Benchee.run(jobs, options)
  end

  defp option_for_tag(nil), do: []

  defp option_for_tag(tag) do
    [save: [path: "priv/day12-#{tag}.benchee", tag: tag]]
  end

  def bench_report() do
    Benchee.run(%{}, load: "priv/day12-*.benchee")
  end

  def main([]), do: nil
  def main(["bench"]), do: Day12Profile.bench()
  def main(["bench", tag]), do: Day12Profile.bench(tag)
  def main(["report"]), do: Day12Profile.bench_report()
  def main(["profile"]), do: Day12Profile.profile()
  def main(["profile", generation]), do: Day12Profile.profile(String.to_integer(generation))
end

Day12Profile.main(System.argv())
