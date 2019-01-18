defmodule Day10Test do
  use ExUnit.Case, async: false

  @moduletag timeout: 10_000

  setup_all do
    [example: example_input(), puzzle: puzzle_input()]
  end

  describe "parse/1" do
    test "example into position and velocity", %{example: example} do
      assert %{px: 7, py: 0, vx: -1, vy: 0} == example |> Enum.fetch!(1)
    end

    test "puzzle into position and velocity", %{puzzle: puzzle} do
      assert %{px: -9855, py: -9873, vx: 1, vy: 1} == puzzle |> Enum.fetch!(1)
    end
  end

  describe "light_at/2" do
    test "fetch light from sky at coordinate", %{example: example} do
      sky = Day10.to_sky(example)
      assert Day10.light_at(sky, {-4, 3})
      refute Day10.light_at(sky, {10, 10})
    end
  end

  describe "light_stream/1" do
    test "stream of light points over time", %{example: example} do
      sky =
        example
        |> Day10.light_stream()
        |> Enum.fetch!(3)

      assert Day10.light_at(sky, {8, 5})
      refute Day10.light_at(sky, {5, 5})
    end

    @tag skip: ""
    test "puzzle stream of light points over time", %{puzzle: puzzle} do
      sky =
        puzzle
        |> Day10.light_stream()
        |> Enum.fetch!(3_000)

      assert Day10.light_at(sky, {0, 0})
    end
  end

  import ExUnit.CaptureIO

  describe "print_sky/1" do
    test "plot light points", %{example: example} do
      print = fn ->
        example
        |> Day10.light_stream()
        |> Enum.fetch!(3)
        |> Day10.print_sky({-6, 15, -4, 11})
      end

      expected = """
      ......................
      ......................
      ......................
      ......................
      ......#...#..###......
      ......#...#...#.......
      ......#...#...#.......
      ......#####...#.......
      ......#...#...#.......
      ......#...#...#.......
      ......#...#...#.......
      ......#...#..###......
      ......................
      ......................
      ......................
      ......................
      """

      assert expected == capture_io(print)
    end

    @tag capture_log: true
    test "puzzle plot light points", %{puzzle: puzzle} do
      extents = Day10.extents(puzzle)
      IO.inspect(extents, label: "extents")
      extents = {50_160, 50_220, -29_880, -29_910}
      IO.inspect(extents, label: "extents override")
      Day10.print_sky(puzzle, extents)
    end
  end

  describe "find_message/1" do
    test "example", %{example: example} do
      {sky, second} =
        example
        |> Day10.light_stream()
        |> Day10.find_message()

      assert 3 == second
      assert Day10.light_at(sky, {8, 5})
      refute Day10.light_at(sky, {5, 5})
    end

    @tag timeout: 500
    test "puzzle", %{puzzle: puzzle} do
      extents = Day10.extents(puzzle)
      IO.inspect(extents, label: "extents")

      {sky, second} =
        puzzle
        |> Day10.light_stream()
        # |> Stream.with_index()
        # |> Stream.each(fn {sky, second} ->
        #   IO.puts("#{second}")
          # Day10.print_sky(sky, extents)
        # end)
        |> Day10.find_message()

      assert 0 == second
      assert Day10.light_at(sky, {8, 5})
      refute Day10.light_at(sky, {5, 5})
    end
  end

  def example_input do
    """
    position=< 9,  1> velocity=< 0,  2>
    position=< 7,  0> velocity=<-1,  0>
    position=< 3, -2> velocity=<-1,  1>
    position=< 6, 10> velocity=<-2, -1>
    position=< 2, -4> velocity=< 2,  2>
    position=<-6, 10> velocity=< 2, -2>
    position=< 1,  8> velocity=< 1, -1>
    position=< 1,  7> velocity=< 1,  0>
    position=<-3, 11> velocity=< 1, -2>
    position=< 7,  6> velocity=<-1, -1>
    position=<-2,  3> velocity=< 1,  0>
    position=<-4,  3> velocity=< 2,  0>
    position=<10, -3> velocity=<-1,  1>
    position=< 5, 11> velocity=< 1, -2>
    position=< 4,  7> velocity=< 0, -1>
    position=< 8, -2> velocity=< 0,  1>
    position=<15,  0> velocity=<-2,  0>
    position=< 1,  6> velocity=< 1,  0>
    position=< 8,  9> velocity=< 0, -1>
    position=< 3,  3> velocity=<-1,  1>
    position=< 0,  5> velocity=< 0, -1>
    position=<-2,  2> velocity=< 2,  0>
    position=< 5, -2> velocity=< 1,  2>
    position=< 1,  4> velocity=< 2,  1>
    position=<-2,  7> velocity=< 2, -2>
    position=< 3,  6> velocity=<-1, -1>
    position=< 5,  0> velocity=< 1,  0>
    position=<-6,  0> velocity=< 2,  0>
    position=< 5,  9> velocity=< 1, -2>
    position=<14,  7> velocity=<-2,  0>
    position=<-3,  6> velocity=< 2, -1>
    """
    |> String.trim_trailing("\n")
    |> String.split("\n")
    |> Day10.parse()
  end

  def puzzle_input() do
    File.stream!("priv/day10.txt")
    |> Day10.parse()
    |> Enum.to_list()
  end
end
