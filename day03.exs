defmodule Day03 do
  def parse_input(lines) do
    lines
    |> Enum.map(&parse_claim/1)
  end

  def parse_claim(input) do
    regex = ~r/#(?<id>\d+) @ (?<left>\d+),(?<top>\d+): (?<width>\d+)x(?<height>\d+)/

    c =
      Regex.named_captures(regex, input)
      |> Enum.into(%{}, fn {k, v} -> {k, String.to_integer(v)} end)

    {
      c["id"],
      {
        c["left"],
        c["top"]
      },
      {
        c["width"],
        c["height"]
      }
    }
  end
end

ExUnit.start(trace: true, seed: 0)

defmodule Day03Test do
  use ExUnit.Case

  describe "part 1" do
    test "parse input to claims" do
      claims = Day03.parse_input(example_input())

      assert {1, {1, 3}, {4, 4}} = Enum.at(claims, 0)
    end

    defp example_input() do
      """
      #1 @ 1,3: 4x4
      #2 @ 3,1: 4x4
      #3 @ 5,5: 2x2
      """
      |> String.split("\n", trim: true)
    end

    defp puzzle_input() do
      File.read!("day03.txt")
      |> String.split("\n", trim: true)
    end
  end
end
