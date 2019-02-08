defmodule Day12Test do
  use ExUnit.Case, async: true

  import Day12

  describe "answer/1" do
    test "example 1" do
      assert 325 == answer(example_input(), 20)
    end

    test "puzzle" do
      assert 0 == answer(puzzle_input(), 20)
    end
  end

  describe "parse/1" do
    test "returns initial state" do
      {state, _} = parse(example_input())
      expected = [0, 3, 5, 8, 9, 16, 17, 18, 22, 23, 24]
      assert expected == state
    end

    test "returns rules"
  end

  def example_input() do
    """
    initial state: #..#.#..##......###...###

    ...## => #
    ..#.. => #
    .#... => #
    .#.#. => #
    .#.## => #
    .##.. => #
    .#### => #
    #.#.# => #
    #.### => #
    ##.#. => #
    ##.## => #
    ###.. => #
    ###.# => #
    ####. => #
    """
  end

  def puzzle_input() do
    File.read!("priv/day12.txt")
  end
end
