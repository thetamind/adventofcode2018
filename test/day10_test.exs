defmodule Day10Test do
  use ExUnit.Case, async: false

  @moduletag timeout: 1_000

  setup_all do
    [example: example_input(), puzzle: puzzle_input()]
  end

  describe "parse/1" do
    test "example into position and velocity", %{example: example} do
      assert {7, 0, -1, 0} == example |> Enum.fetch!(1)
    end

    test "puzzle into position and velocity", %{puzzle: puzzle} do
      assert {-9855, -9873, 1, 1} == puzzle |> Enum.fetch!(1)
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

  describe "find_message_zero_origin/1" do
    test "example - zero origin strategy", %{example: example} do
      {sky, second} =
        example
        |> Day10.light_stream()
        |> Day10.find_message_zero_origin()

      assert 3 == second
      assert Day10.light_at(sky, {8, 5})
      refute Day10.light_at(sky, {5, 5})
    end
  end

  @tag :wip
  describe "find_message_vertical/1" do
    test "example", %{example: example} do
      {sky, second, _score} =
        example
        |> Day10.light_stream()
        |> Day10.find_message_vertical()

      assert 3 == second
      assert Day10.light_at(sky, {8, 5})
    end
  end

  @tag :wip
  describe "find_message_extents/1" do
    test "example", %{example: example} do
      {sky, second, _extents} =
        example
        |> Day10.light_stream()
        |> Day10.find_message_extents()

      assert 3 == second
      assert Day10.light_at(sky, {8, 5})
    end

    @tag :wip
    @tag timeout: 15_000
    test "puzzle", %{puzzle: puzzle} do
      extents = Day10.extents(puzzle)
      IO.inspect(extents, label: "extents")

      {sky, second} =
        puzzle
        |> Day10.light_stream()
        |> Day10.find_message_extents()

      assert 0 == second
      assert Day10.light_at(sky, {8, 5})
      refute Day10.light_at(sky, {5, 5})
    end
  end

  @tag :wip
  describe "score_vertical/1" do
    test "equivalent" do
      sky = [5, 5, 5, 5, 5, 9, 9, 9, 9, 9, 9, 9, 1, 2, 3] |> Enum.map(&{&1, 0, 0, 0})

      assert 12 == Day10.score_vertical(sky)
      assert 12 == Day10.score_vertical_reduce(sky)
      assert 12 == Day10.score_vertical_group_by(sky)
    end

    @tag :bench
    test "performance" do
      numbers = fn ->
        Stream.unfold(:rand.seed_s(:exsplus), &:rand.uniform_s/1)
        |> Stream.map(&(floor(&1 * 200) - 100))
      end

      to_sky = fn numbers ->
        Stream.map(numbers, &{&1, 0, 0, 0})
      end

      make_sky = fn count -> Stream.take(to_sky.(numbers.()), count) end

      inputs = %{
        "Medium (100,000)" => make_sky.(100_000),
        "Large (1,000,000)" => make_sky.(1_000_000)
      }

      Benchee.run(
        %{
          "group_by" => fn sky -> Day10.score_vertical_group_by(sky) end,
          "reduce" => fn sky -> Day10.score_vertical_reduce(sky) end,
          "better" => fn sky -> Day10.score_vertical(sky) end
        },
        time: 4,
        memory_time: 1,
        inputs: inputs
      )
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
