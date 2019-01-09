defmodule Day9Test do
  use ExUnit.Case, async: true

  test "me", %{sample: sample} do
    assert sample
  end

  setup_all do
    [sample: sample_input()]
  end

  def sample_input do
    "9 players; last marble is worth 25 points: high score is 32"
    |> parse()
  end

  def parse(line) do
    pattern =
      ~r/(?<players>\d+) players; last marble is worth (?<marble>\d+) points: high score is (?<score>\d+)/

    Regex.named_captures(pattern, line)
    |> Enum.into(%{}, fn {k, v} -> {String.to_atom(k), String.to_integer(v)} end)
  end
end

defmodule Day9.CircleTest do
  use ExUnit.Case, async: true

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
end
