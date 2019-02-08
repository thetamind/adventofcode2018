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

  describe "next_gen/2" do
    test "simple" do
      rules = [
        {{false, false, false, true, true}, true}
      ]

      state = [0, 5, 6]

      assert [4] == next_gen(state, rules)
    end
  end

  describe "apply_rule/2" do
    test "match" do
      rule = {{false, false, true}, true}
      values = {false, false, true}
      assert {:match, true} == apply_rule(values, rule)
    end

    test "no match" do
      rule = {{true, false, true}, true}
      values = {false, false, false}
      assert nil == apply_rule(values, rule)
    end
  end

  describe "parse/1" do
    test "returns initial state" do
      {state, _} = parse(example_input())
      expected = [0, 3, 5, 8, 9, 16, 17, 18, 22, 23, 24]
      assert expected == state
    end

    test "returns rules" do
      {_, rules} = parse(example_input())
      assert {{false, false, false, true, true}, true} == List.first(rules)
    end
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
