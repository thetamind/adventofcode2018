defmodule Day12Test do
  use ExUnit.Case, async: true

  import Day12

  @moduletag timeout: 2_000

  describe "answer/1" do
    test "example 1" do
      assert 325 == answer(example_input(), 20)
    end

    test "example WOOT" do
      assert 59374 == answer(example_input(), 3000)
    end

    test "puzzle" do
      assert 2349 == answer(puzzle_input(), 20)
    end

    test "puzzle part 2" do
      assert 2_100_000_001_168 == answer(puzzle_input(), 50_000_000_000)
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

  describe "pot_stream/1" do
    setup do
      [stream: pot_stream([0, 3, 5, 8, 9, 15, 16])]
    end

    test "begins before first populated pot", %{stream: stream} do
      # left -4, centre -2, right 0
      assert {-2, {false, false, false, false, true}} == Enum.at(stream, -2 + 2)
    end

    test "first populated pot", %{stream: stream} do
      # left -2, centre 0, right 2
      assert {0, {false, false, true, false, false}} == Enum.at(stream, 0 + 2)
      # left -1, centre 1, right 3
      assert {1, {false, true, false, false, true}} == Enum.at(stream, 1 + 2)
    end

    test "last populated pot", %{stream: stream} do
      # left 14, centre 16, right 18
      assert {16, {false, true, true, false, false}} == Enum.at(stream, 16 + 2)
    end

    test "ends after last populated pot", %{stream: stream} do
      # left 16, centre 18, right 20
      assert {18, {true, false, false, false, false}} == Enum.at(stream, 18 + 2)
      # past the end
      assert nil == Enum.at(stream, 19 + 2)
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
