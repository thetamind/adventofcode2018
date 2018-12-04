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
end

ExUnit.start()

defmodule Day01Test do
  use ExUnit.Case, async: true

  test "examples" do
    assert 3 == Day01.solve("+1, +1, +1")
    assert 0 = Day01.solve("+1, +1, -2")
    assert -6 = Day01.solve("-1, -2, -3")
  end

  test "puzzle" do
    input = File.read!("day01.txt")
    |> String.split("\n", trim: true)
    |> Enum.join(", ")
    assert 400 == Day01.solve(input)
  end
end
