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
    |> Enum.map(&parse_num/1)
    # [+3, +3, +4, -2, -4]...
    # [+3, +6, 10, +8, +4, +7, 10]
    # {[3],3}, {[3,6], 6}, {[3,6,10],10}
    # [3], [6,3], [10,6,3], [8, 10, 6, 3]
    # |> Enum.sum()
    # |> Enum.sc
    |> Enum.reduce_while([0], fn digit, acc ->
        [last | _rest] = acc
        sum = digit + last

      if Enum.member?(acc, sum) do
        {:halt, sum}
      else
        {:cont, [sum | acc]}
      end
    end)
  end
end

ExUnit.start()

defmodule Day01Test do
  use ExUnit.Case, async: true

  test "examples" do
    assert 3 == Day01.solve("+1, +1, +1")
    assert 0 == Day01.solve("+1, +1, -2")
    assert -6 == Day01.solve("-1, -2, -3")
  end

  test "puzzle" do
    input =
      File.read!("day01.txt")
      |> String.split("\n", trim: true)
      |> Enum.join(", ")

    assert 400 == Day01.solve(input)
  end

  test "part 2 examples" do
    assert 0 == Day01.part2("+1, -1")
    assert 10 == Day01.part2("+3, +3, +4, -2, -4")
    assert 5 == Day01.part2("-6, +3, +8, +5, -6")
    assert 14 == Day01.part2("+7, +7, -2, -7, -4")
  end

  test "part 2 puzzle" do
    input =
      File.read!("day01.txt")
      |> String.split("\n", trim: true)
      |> Enum.join(", ")

    assert 400 == Day01.part2(input) |> Enum.take(-30)
  end
end
