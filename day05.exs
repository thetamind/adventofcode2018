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

  def part2(polymer) do
    choices(polymer)
    |> Enum.sort_by(fn {_, length, _} -> length end, &<=/2)
    |> Enum.at(0)
  end

  @patterns Enum.map(?a..?z, fn unit ->
              pattern = ~r/[#{<<unit>>}|#{String.upcase(<<unit>>)}]/
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
