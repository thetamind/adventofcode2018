
defmodule Day5Test do
  use ExUnit.Case, async: true

  describe "small example" do
    test "polymer reaction shrinks matching pairs" do
      assert "" == Day5.shrink("aA")
    end

    test "polymer reaction shrinks matching pairs recursively" do
      assert "" == Day5.shrink("abBA")
    end

    test "no reaction of units of different type" do
      assert "abAB" == Day5.shrink("abAB")
    end

    test "no reaction of units of same type and matching polarity" do
      assert "aabAAB" == Day5.shrink("aabAAB")
    end
  end

  describe "large example" do
    test "polymer reaction shrinks matching pairs" do
      assert "dabCBAcaDA" == Day5.shrink("dabAcCaCBAcCcaDA")
    end
  end

  describe "part 2 example" do
    test "determine which type to remove to produce shortest polymer" do
      assert {"c", 4, "daDA"} == Day5.part2("dabAcCaCBAcCcaDA")
    end
  end

  describe "puzzle" do
    test "polymer reaction shrinks matching pairs" do
      input = File.read!("day05.txt") |> String.trim_trailing("\n")
      assert 11720 == Day5.shrink(input) |> String.length()
    end

    test "determine which type to remove to produce shortest polymer" do
      input = File.read!("day05.txt") |> String.trim_trailing("\n")
      assert {"w", 4956, _} = Day5.part2(input)
    end

    test "concurrently determine which type to remove to produce shortest polymer" do
      input = File.read!("day05.txt") |> String.trim_trailing("\n")
      assert {"w", 4956, _} = Day5.concurrent_part2(input)
    end
  end
end
