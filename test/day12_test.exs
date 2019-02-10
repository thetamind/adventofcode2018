defmodule Day12Test do
  use ExUnit.Case, async: true

  import Day12

  @moduletag timeout: 10_000

  describe "answer/1" do
    test "example 1" do
      assert 325 == answer(example_input(), 20)
    end

    test "puzzle" do
      assert 2349 == answer(puzzle_input(), 20)
    end

    test "puzzle part 2" do
      assert 0 == answer(puzzle_input(), 50_000_000_000)
    end
  end

  describe "next_gen/2" do
    test "simple" do
      rules =
        prepare_rules([
          {{false, false, false, true, true}, true}
        ])

      state = [0, 5, 6]

      assert [4] == next_gen(state, rules)
    end

    test "negative" do
      rules =
        prepare_rules([
          {{false, false, false, true, true}, true}
        ])

      state = [0, 1]

      assert [-1] == next_gen(state, rules)
    end
  end

  describe "apply_rules/2" do
    test "match" do
      rules = prepare_rules([{{false, false, true}, true}])
      values = {false, false, true}
      assert true == apply_rules(values, rules)
    end

    test "no match" do
      rules = prepare_rules([{{true, false, true}, true}])
      values = {false, false, false}
      assert nil == apply_rules(values, rules)
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
