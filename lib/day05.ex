defmodule Day5 do
  def shrink(polymer) do
    do_shrink(polymer, "")
  end

  def do_shrink(<<right, rest::binary>>, <<left, acc::binary>>) when abs(right - left) == 32 do
    do_shrink(rest, acc)
  end

  def do_shrink(<<right, rest::binary>>, <<acc::binary>>) do
    do_shrink(rest, <<right>> <> acc)
  end

  def do_shrink("", acc) do
    String.to_charlist(acc) |> Enum.reverse() |> to_string()
  end

  def part2(polymer) do
    choices(polymer)
    |> Enum.sort_by(fn {_, length, _} -> length end, &<=/2)
    |> Enum.at(0)
  end

  @patterns Enum.map(?a..?z, fn unit ->
              pattern = ~r/[#{<<unit>>}|#{String.upcase(<<unit>>, :ascii)}]/
              {<<unit>>, pattern}
            end)

  def choices(polymer) do
    Enum.map(@patterns, fn {unit, pattern} ->
      shrunk = String.replace(polymer, pattern, "") |> shrink()

      length = String.length(shrunk)

      {unit, length, shrunk}
    end)
  end

  def concurrent_part2(polymer) do
    @patterns
    |> Task.async_stream(
      fn {unit, pattern} ->
        shrunk = String.replace(polymer, pattern, "") |> shrink()

        length = String.length(shrunk)

        {unit, length, shrunk}
      end,
      ordered: false,
      max_concurrency: 26
    )
    |> Stream.map(fn {:ok, res} -> res end)
    |> Enum.min_by(fn {_, length, _} -> length end)
  end
end
