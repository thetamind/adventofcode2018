defmodule Day6Test do
  use ExUnit.Case, async: true

  describe "grid" do
    @tag skip: "Rework grid labeling"
    test "example" do
      expected =
        """
        ..........
        .A........
        ..........
        ........C.
        ...D......
        .....E....
        .B........
        ..........
        ..........
        ........F.
        """
        |> String.trim_trailing("\n")

      coordinates = [
        {1, 1},
        {1, 6},
        {8, 3},
        {3, 4},
        {5, 5},
        {8, 9}
      ]

      assert expected == Day6.Grid.plot(coordinates) |> Day6.Grid.inspect()
    end

    @tag skip: "Rework grid labeling"
    test "example with distance" do
      expected =
        """
        aaaaa.cccc
        aAaaa.cccc
        aaaddecccc
        aadddeccCc
        ..dDdeeccc
        bb.deEeecc
        bBb.eeee..
        bbb.eeefff
        bbb.eeffff
        bbb.ffffFf
        """
        |> String.trim_trailing("\n")

      coordinates = [
        {1, 1},
        {1, 6},
        {8, 3},
        {3, 4},
        {5, 5},
        {8, 9}
      ]

      assert expected == Day6.Grid.plot_distance(coordinates) |> Day6.Grid.inspect()
    end
  end

  describe "example" do
    test "largest area" do
      coordinates = [
        {1, 1},
        {1, 6},
        {8, 3},
        {3, 4},
        {5, 5},
        {8, 9}
      ]

      assert {"E", 17} = Day6.largest_area(coordinates, 9)
    end

    test "manhattan sum" do
      coordinates = [
        {1, 1},
        {1, 6},
        {8, 3},
        {3, 4},
        {5, 5},
        {8, 9}
      ]

      grid = Day6.Grid.manhattan_sums(coordinates, 9)
      lookup = Day6.Grid.to_lookup(grid)

      IO.puts("\n")

      labeller =
        lookup
        |> Map.values()
        |> Day6.Grid.ascii_labeller()
        |> Day6.Grid.pixel_for()

      grid
      |> Day6.Grid.label_grid(labeller)
      |> Day6.Grid.inspect()
      |> IO.puts()

      assert 30 = Day6.manhattan_sum(lookup, {4, 3})
      assert 16 = Day6.safe_region_size(lookup, 32)
    end
  end

  describe "puzzle" do
    test "largest area" do
      coordinates =
        File.read!("priv/day06.txt")
        |> String.split("\n", trim: true)
        |> Enum.map(&parse_coordinate/1)

      size =
        Day6.Grid.extents(coordinates)
        |> Tuple.to_list()
        |> Enum.max()

      assert {"i", 3840} = Day6.largest_area(coordinates, size)
    end

    test "manhattan sum" do
      coordinates =
        File.read!("priv/day06.txt")
        |> String.split("\n", trim: true)
        |> Enum.map(&parse_coordinate/1)

      size =
        Day6.Grid.extents(coordinates)
        |> Tuple.to_list()
        |> Enum.max()

      grid = Day6.Grid.manhattan_sums(coordinates, size)
      lookup = Day6.Grid.to_lookup(grid)

      assert 46_542 == Day6.safe_region_size(lookup, 10_000)
    end
  end

  def parse_coordinate(string) do
    string
    |> String.split(", ")
    |> Enum.map(&String.to_integer/1)
    |> List.to_tuple()
  end
end

defmodule Day6.BinTest do
  use ExUnit.Case, async: true

  test "step" do
    assert [1, 3, 5, 7, 9] == Day6.Grid.step(1, 10, 2)
  end

  test "make bins 1" do
    values = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
    labels = ~w(A B C D E)

    bins = Day6.Grid.make_bins(values, labels)
    assert [1, 3, 5, 7, 9] == bins
  end

  test "make bins 2" do
    values = [18, 25, 30, 50]
    labels = ~w(1 2 3 4 5 6)

    bins = Day6.Grid.make_bins(values, labels)
    assert [18, 24, 30, 36, 42, 48] == bins
  end

  test "pixel_for" do
    labels = [
      {28, " "},
      {32, "."},
      {36, "○"},
      {40, "☼"},
      {44, "•"},
      {48, "❄"}
    ]

    lookup = Day6.Grid.pixel_for(labels)
    pixel_for = &lookup.({0, 0}, &1)

    assert "." = pixel_for.(32)
    assert "." = pixel_for.(33)
    assert "." = pixel_for.(34)
    assert "○" = pixel_for.(36)
    assert "❄" = pixel_for.(99)
  end
end
