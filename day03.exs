defmodule Day03 do
  defmodule Claim do
    defstruct [:id, :left, :top, :width, :height]

    @type t :: %Claim{
            id: non_neg_integer,
            left: non_neg_integer,
            top: non_neg_integer,
            width: non_neg_integer,
            height: non_neg_integer
          }
  end

  def parse_input(lines) do
    lines
    |> Enum.map(&parse_claim/1)
  end

  def parse_claim(input) do
    regex = ~r/#(?<id>\d+) @ (?<left>\d+),(?<top>\d+): (?<width>\d+)x(?<height>\d+)/

    captures =
      Regex.named_captures(regex, input)
      |> Enum.into(%{}, fn {k, v} -> {String.to_existing_atom(k), String.to_integer(v)} end)

    Map.merge(%Claim{}, captures)
  end
end

ExUnit.start(trace: true, seed: 0)

defmodule Day03Test do
  use ExUnit.Case

  alias Day03.Claim

  describe "part 1" do
    test "parse input to claims" do
      claims = Day03.parse_input(example_input())
      claim = Enum.at(claims, 0)

      assert %Claim{id: 1, left: 1, top: 3, width: 4, height: 4} = claim
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
