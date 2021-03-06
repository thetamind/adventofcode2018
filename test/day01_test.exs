defmodule Day01Test do
  use ExUnit.Case, async: true

  test "examples" do
    assert 3 == Day01.solve("+1, +1, +1")
    assert 0 == Day01.solve("+1, +1, -2")
    assert -6 == Day01.solve("-1, -2, -3")
  end

  test "puzzle" do
    input =
      File.read!("priv/day01.txt")
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
      File.read!("priv/day01.txt")
      |> String.split("\n", trim: true)
      |> Enum.join(", ")

    assert 232 == Day01.part2(input)
  end
end
