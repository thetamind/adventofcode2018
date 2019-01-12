defmodule Day9Test do
  use ExUnit.Case, async: false

  @moduletag timeout: 500

  setup_all do
    [examples: example_input(), puzzle: puzzle_input()]
  end

  describe "take_turn" do
    test "place marble" do
      game =
        Day9.new(9)
        |> Day9.take_turn(1)

      assert {1, [0, 1]} = Day9.inspect_circle(game)

      game = Day9.take_turn(game, 2)
      assert {2, [0, 2, 1]} = Day9.inspect_circle(game)
    end

    test "place marble multiple of 23" do
      game = Day9.play(9, 22)

      assert {22,
              [0, 16, 8, 17, 4, 18, 9, 19, 2, 20, 10, 21, 5, 22, 11, 1, 12, 6, 13, 3, 14, 7, 15]} ==
               Day9.inspect_circle(game)

      game = Day9.take_turn(game, 23)

      assert {19, [0, 16, 8, 17, 4, 18, 19, 2, 20, 10, 21, 5, 22, 11, 1, 12, 6, 13, 3, 14, 7, 15]} ==
               Day9.inspect_circle(game)

      assert 32 == Day9.player_score(game, 5)
    end
  end

  describe "next_player" do
    test "increment player" do
      stream = Stream.iterate(Day9.new(3), &Day9.next_player/1)

      assert 0 == Enum.fetch!(stream, 0) |> Map.get(:current_player)
      assert 1 == Enum.fetch!(stream, 1) |> Map.get(:current_player)
      assert 2 == Enum.fetch!(stream, 2) |> Map.get(:current_player)
      assert 0 == Enum.fetch!(stream, 3) |> Map.get(:current_player)
      assert 1 == Enum.fetch!(stream, 4) |> Map.get(:current_player)
    end
  end

  test "examples", %{examples: examples} do
    Enum.map(examples, fn example ->
      assert example.score ==
               Day9.play(example.players, example.marble)
               |> Day9.highest_score()
    end)
  end

  test "puzzle", %{puzzle: puzzle} do
    assert 422_748 ==
             Day9.play(puzzle.players, puzzle.marble)
             |> Day9.highest_score()
  end

  def example_input do
    [
      "9 players; last marble is worth 25 points: high score is 32",
      "10 players; last marble is worth 1618 points: high score is 8317",
      "13 players; last marble is worth 7999 points: high score is 146373",
      "17 players; last marble is worth 1104 points: high score is 2764",
      "21 players; last marble is worth 6111 points: high score is 54718",
      "30 players; last marble is worth 5807 points: high score is 37305"
    ]
    |> Enum.map(&parse/1)
  end

  def puzzle_input() do
    File.read!("priv/day09.txt")
    |> String.trim_trailing("\n")
    |> parse()
  end

  def parse(line) do
    pattern =
      ~r/(?<players>\d+) players; last marble is worth (?<marble>\d+) points(: high score is (?<score>\d+))?/

    Regex.named_captures(pattern, line)
    |> Enum.reject(fn {_, v} -> v == "" end)
    |> Enum.into(%{}, fn {k, v} -> {String.to_atom(k), String.to_integer(v)} end)
  end
end

defmodule Day9.CircleTest do
  use ExUnit.Case, async: false

  alias Day9.Circle

  describe "navigate" do
    test "clockwise" do
      circle = Circle.new([0, 1, 2, 3])
      assert {2, _} = circle |> Circle.next() |> Circle.next() |> Circle.pop()
    end

    test "clockwise cyclic" do
      circle = Circle.new([0, 1, 2, 3])

      assert {0, _} =
               circle
               |> Circle.next()
               |> Circle.next()
               |> Circle.next()
               |> Circle.next()
               |> Circle.pop()
    end

    test "counter-clockwise" do
      circle = Circle.new([0, 1, 2, 3])
      assert {2, _} = circle |> Circle.prev() |> Circle.prev() |> Circle.pop()
    end

    test "counter-clockwise cyclic" do
      circle = Circle.new([0, 1, 2, 3])

      assert {0, _} =
               circle
               |> Circle.prev()
               |> Circle.prev()
               |> Circle.prev()
               |> Circle.prev()
               |> Circle.pop()
    end
  end

  describe "pop" do
    test "removes current item" do
      circle = Circle.new([0, 1, 2, 3])
      assert {2, circle} = circle |> Circle.next() |> Circle.next() |> Circle.pop()
      assert {3, circle} = Circle.pop(circle)
      assert {0, circle} = Circle.pop(circle)
      assert {1, circle} = Circle.pop(circle)
    end
  end

  describe "peek" do
    test "peek" do
      circle = Circle.new([0, 1, 2, 3])
      assert 0 == circle |> Circle.peek()
      assert 1 == circle |> Circle.next() |> Circle.peek()
      assert 3 == circle |> Circle.prev() |> Circle.peek()
      assert 2 == circle |> Circle.prev() |> Circle.prev() |> Circle.peek()
    end
  end

  describe "insert" do
    test "insert" do
      circle =
        Circle.new([0, 1, 2, 3])
        |> Circle.next()
        |> Circle.next()
        |> Circle.insert(99)

      assert {99, _} = Circle.pop(circle)
    end
  end

  @tag timeout: 500
  describe "to_list" do
    test "to_list" do
      circle = Circle.new([0, 1, 2, 3]) |> Circle.prev()
      assert [0, 1, 2, 3] = Circle.to_list(circle)
    end
  end
end
