defmodule Day5 do
  def shrink(polymer) do
    IO.inspect(polymer, label: "Shrinking... ")
    do_shrink(polymer, "")
  end

  def do_shrink(<<a, aa, rest::bitstring>>, result) when abs(aa - a) == 32 do
    IO.inspect("#{a} #{aa} #{<<a, aa>>}", label: "match 32", binaries: :as_strings)
    do_shrink(rest, result)
  end

  def do_shrink(<<a, b, rest::bitstring>>, result) when not a == b do
    IO.inspect(rest, label: "rest", binaries: :as_strings)

    do_shrink(<<b>> <> rest, <<a>> <> result)
  end

  def do_shrink(<<>>, result), do: result
end

ExUnit.start(seed: 0, trace: true)

defmodule Day5Test do
  use ExUnit.Case, async: true

  describe "small example" do
    test "polymer reactton shrinks matching pairs" do
      assert "" == Day5.shrink("aA")
    end

    test "polymer reaction shrinks matching pairs recursively" do
      assert "" == Day5.shrink("abBA")
    end

    test "c" do
      assert "abAB" == Day5.shrink("abAB")
    end

    test "d" do
      assert "aabAAB" == Day5.shrink("aabAAB")
    end
  end
end



# a b B A
# ^ ^ rest
# a b B A
#   ^ ^ rest
# a b B A
#     ^ ^
