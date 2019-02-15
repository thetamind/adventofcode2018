defmodule Day13.SimulationTest do
  use ExUnit.Case, async: true

  alias Day13.{TrackMap, Simulation}

  describe "new/1" do
    test "creates Simulation" do
      input = ~S"""
      /--->-\
      |     |
      |  /--+--\
      |  |  |  |
      \--+>-/  |
         |     |
         \-----/
      """

      {map, carts} = TrackMap.parse(input)
      simulation = Simulation.new(map, carts)

      assert %Simulation{} = simulation
    end
  end

  describe "next_tick" do
    test "moves carts" do
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
      simulation = Simulation.new(map, carts)

      frame1 = Simulation.next_tick(simulation)
      assert {{0, 2}, :down} == List.first(frame1.carts)
      assert {{0, 4}, :up} == List.last(frame1.carts)

      frame2 = Simulation.next_tick(frame1)
      assert {{0, 3}, :down} == List.first(frame2.carts)
      assert {{0, 3}, :up} == List.last(frame2.carts)
    end

    test "moves carts around corners" do
      input = ~S"""
      /--->-\
      |     |
      |  /--+--\
      |  |  |  |
      \--+>-/  |
         |     |
         \-----/
      """

      {map, carts} = TrackMap.parse(input)
      frame0 = Simulation.new(map, carts)

      frame2 =
        frame0
        |> Simulation.next_tick()
        |> Simulation.next_tick()

      assert {{6, 0}, :down} == List.first(frame2.carts)
      assert {{6, 4}, :up} == List.last(frame2.carts)
    end

    test "detect collisions" do
      input = ~S"""
      /--->-\
      |     |
      |  /--+--\
      |  |  |  |
      \--+>-/  |
         |     |
         \-----/
      """

      {map, carts} = TrackMap.parse(input)
      frame0 = Simulation.new(map, carts)

      frame4 =
        frame0
        |> Simulation.next_tick()
        |> Simulation.next_tick()
        |> Simulation.next_tick()
        |> Simulation.next_tick()

      assert {{6, 2}, :down} == List.first(frame4.carts)
      assert {{6, 2}, :up} == List.last(frame4.carts)

      assert [{6, 2}] == frame4.collisions
    end
  end
end

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
