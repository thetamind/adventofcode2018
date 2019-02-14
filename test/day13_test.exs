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

      {map, carts} = TrackMap.parse(input)

      assert :curve_r == TrackMap.get(map, {0, 0})
      assert :curve_r == TrackMap.get(map, {6, 4})
      assert :curve_l == TrackMap.get(map, {3, 6})
      assert :intersection == TrackMap.get(map, {3, 4})
      assert :empty == TrackMap.get(map, {1, 1})

      assert Enum.empty?(carts)
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

      {map, carts} = TrackMap.parse(input)

      assert :vertical == TrackMap.get(map, {0, 1})
      assert :vertical == TrackMap.get(map, {0, 5})

      assert {{0, 1}, :down} == List.first(carts)
      assert {{0, 5}, :up} == List.last(carts)
    end

    test "example 3 carts" do
      input = ~S"""
      /->-\
      |   |  /----\
      | /-+--+-\  |
      | | |  | v  |
      \-+-/  \-+--/
        \------/
      """

      {map, carts} = TrackMap.parse(input)

      assert :horizontal == TrackMap.get(map, {2, 0})
      assert :vertical == TrackMap.get(map, {9, 3})

      assert {{2, 0}, :right} == List.first(carts)
      assert {{9, 3}, :down} == List.last(carts)
    end

    test "ignore blank lines" do
      input = ~S"""
      /--\
      \--/


      """

      {map, _carts} = TrackMap.parse(input)
      assert 2 == tuple_size(map)
    end
  end

  def puzzle_input() do
    File.read!("priv/day13.txt")
  end
end