defmodule Day13.TrackMapTest do
  use ExUnit.Case, async: true

  alias Day13.TrackMap

  describe "parse/1" do
    test "example 1 intersecting track" do
      input = ~S"""
      /-----\
      |     |
      |  /--+--\
      |  |  |  |
      \--+--/  |
         |     |
         \-----/
      """

      map = TrackMap.parse(input)

      assert :curve_r == TrackMap.get(map, {0, 0})
      assert :curve_r == TrackMap.get(map, {6, 4})
      assert :curve_l == TrackMap.get(map, {3, 6})
      assert :intersection == TrackMap.get(map, {3, 4})
      assert :empty == TrackMap.get(map, {1, 1})
    end

    test "example 2 carts" do
      input = ~S"""
      |
      v
      |
      |
      |
      ^
      |
      """

      map = TrackMap.parse(input)

      assert :cart_down == TrackMap.get(map, {0, 1})
      assert :cart_up == TrackMap.get(map, {0, 5})
    end

    test "ignore blank lines" do
      input = ~S"""
      /--\
      \--/


      """

      map = TrackMap.parse(input)
      assert 2 == tuple_size(map)
    end
  end

  def puzzle_input() do
    File.read!("priv/day13.txt")
  end
end
