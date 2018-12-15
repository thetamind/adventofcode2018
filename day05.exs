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
    String.reverse(acc)
  end
end

ExUnit.start(seed: 0, trace: true)

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

  describe "puzzle" do
    test "polymer reaction shrinks matching pairs" do
      input = File.read!("day05.txt") |> String.trim_trailing("\n")
      assert 11720 == Day5.shrink(input) |> String.length()
    end
  end
end
