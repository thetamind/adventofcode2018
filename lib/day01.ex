defmodule Day01 do
  def parse_num("+" <> digit) do
    String.to_integer(digit)
  end

  def parse_num("-" <> digit) do
    String.to_integer(digit) * -1
  end

  def solve(input) do
    input
    |> String.split(", ")
    |> Enum.map(&parse_num/1)
    |> Enum.sum()
  end

  def part2(input) do
    input
    |> String.split(", ")
    |> Stream.map(&parse_num/1)
    |> Stream.cycle()
    |> Enum.reduce_while({0, MapSet.new([0])}, fn digit, {last, seen} ->
      sum = digit + last

      if Enum.member?(seen, sum) do
        {:halt, sum}
      else
        {:cont, {sum, MapSet.put(seen, sum)}}
      end
    end)
  end
end
