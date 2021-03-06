defmodule Day13Test do
  use ExUnit.Case, async: true

  @moduletag timeout: 20_000

  alias Day13.{TrackMap, Simulation}

  describe "first_crash/1" do
    test "example 1" do
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

      crash_frame = Day13.first_crash(simulation)

      assert 2 == crash_frame.frame
      assert {0, 3} == List.first(crash_frame.collisions)
    end

    test "example 2" do
      input = ~S"""
      /->-\
      |   |  /----\
      | /-+--+-\  |
      | | |  | v  |
      \-+-/  \-+--/
        \------/
      """

      {map, carts} = TrackMap.parse(input)
      simulation = Simulation.new(map, carts)

      crash_frame = Day13.first_crash(simulation)

      assert crash_frame, "Could not find crash"
      assert 14 == crash_frame.frame
      assert {7, 3} == List.first(crash_frame.collisions)
    end

    test "puzzle" do
      input = File.read!("priv/day13.txt")

      {map, carts} = TrackMap.parse(input)
      simulation = Simulation.new(map, carts)

      crash_frame = Day13.first_crash(simulation)

      assert crash_frame, "Could not find crash"
      assert 242 == crash_frame.frame
      assert {83, 121} == List.first(crash_frame.collisions)
    end

    test "example part 2" do
      input = ~S"""
      />-<\
      |   |
      | /<+-\
      | | | v
      \>+</ |
        |   ^
        \<->/
      """

      {map, carts} = TrackMap.parse(input)
      simulation = Simulation.new(map, carts)

      frame = Day13.last_cart(simulation)

      assert frame, "Could not find cart"
      assert 3 == frame.frame

      assert [{{6, 4}, _, _}] = frame.carts
    end

    test "puzzle part 2" do
      input = File.read!("priv/day13.txt")

      {map, carts} = TrackMap.parse(input)
      simulation = Simulation.new(map, carts)

      frame = Day13.last_cart(simulation)

      assert frame, "Could not find cart"
      assert 11835 == frame.frame

      assert [{{102, 144}, _, _}] = frame.carts
    end
  end
end

defmodule Day13.SimulationTest do
  use ExUnit.Case, async: true

  @moduletag timeout: 2_000

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
      assert {{0, 2}, :down, _} = List.first(frame1.carts)
      assert {{0, 4}, :up, _} = List.last(frame1.carts)

      frame2 = Simulation.next_tick(frame1)
      assert [] == frame2.carts
      assert [{0, 3}] = frame2.collisions
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

      assert {{6, 0}, :down, _} = List.first(frame2.carts)
      assert {{6, 4}, :up, _} = List.last(frame2.carts)
    end

    test "carts follow turn sequence at intersections" do
      map_lookup = fn {_x, _y} ->
        :intersection
      end

      cart = {{0, 0}, :up, :left}

      cart = Simulation.rotate_cart(cart, map_lookup)
      assert {{_, _}, :left, _} = cart

      cart = Simulation.rotate_cart(cart, map_lookup)
      assert {{_, _}, :left, _} = cart

      cart = Simulation.rotate_cart(cart, map_lookup)
      assert {{_, _}, :up, _} = cart

      cart = Simulation.rotate_cart(cart, map_lookup)
      assert {{_, _}, :left, _} = cart
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

      assert [] == frame4.carts

      assert [{6, 2}] == frame4.collisions
    end

    test "detect collisions while moving" do
      input = ~S"""
      /---\
      | />+<--\
      | | ^   |
      \-+-/   |
        \-----/
      """

      {map, carts} = TrackMap.parse(input)
      frame0 = Simulation.new(map, carts)

      frame1 = Simulation.next_tick(frame0)
      frame2 = Simulation.next_tick(frame1)

      assert [] == frame0.collisions

      assert [{4, 1}] == frame1.collisions
      assert [] == frame2.collisions

      assert [{{4, 1}, :left, _}] = frame1.carts
      assert [{{3, 1}, :left, _}] = frame2.carts
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

  describe "get/2" do
    setup do
      input = ~S"""
      /->-\
      |   |  /----\
      | /-+--+-\  |
      | | |  | v  |
      \-+-/  \-+--/
        \------/
      """

      {map, carts} = TrackMap.parse(input)

      [map: map, carts: carts]
    end

    test "tile exists", %{map: map} do
      assert :horizontal == TrackMap.get(map, {2, 0})
      assert :vertical == TrackMap.get(map, {4, 3})
    end

    test "tile is empty because row is shorter", %{map: map} do
      assert :empty == TrackMap.get(map, {7, 0})
    end
  end

  describe "size/1" do
    test "map" do
      input = ~S"""
      /->-\
      |   |  /----\
      | /-+--+-\  |
      | | |  | v  |
      \-+-/  \-+--/
        \------/
      """

      {map, _carts} = TrackMap.parse(input)

      assert {13, 6} == TrackMap.size(map)
    end
  end

  def puzzle_input() do
    File.read!("priv/day13.txt")
  end
end

defmodule Day13.InspectTest do
  use ExUnit.Case, async: true

  alias Day13.{Inspect, Simulation, TrackMap}

  describe "ascii_map/2" do
    test "reproduces input" do
      input =
        ~S"""
        /->-\
        |   |  /----\
        | /-+--+-\  |
        | | |  | v  |
        \-+-/  \-+--/
          \------/
        """
        |> String.trim_trailing("\n")

      {map, carts} = TrackMap.parse(input)
      simulation = Simulation.new(map, carts)

      actual = Inspect.ascii_map(simulation)

      assert String.replace(input, " ", "") == String.replace(actual, " ", "")
      assert String.bag_distance(input, actual) >= 0.86
      assert String.jaro_distance(input, actual) >= 0.90
    end

    test "draw collisions" do
      input =
        ~S"""
        |
        v
        |
        |
        |
        ^
        |
        """
        |> String.trim_trailing("\n")

      expected =
        ~S"""
        |
        |
        |
        X
        |
        |
        |
        """
        |> String.trim_trailing("\n")

      {map, carts} = TrackMap.parse(input)
      simulation = Simulation.new(map, carts)

      frame2 =
        simulation
        |> Simulation.next_tick()
        |> Simulation.next_tick()

      actual = Inspect.ascii_map(frame2)

      assert String.replace(expected, " ", "") == String.replace(actual, " ", "")
      assert String.bag_distance(expected, actual) >= 1.0
      assert String.jaro_distance(expected, actual) >= 1.0
    end
  end
end
