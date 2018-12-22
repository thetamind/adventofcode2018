defmodule Day6 do
  def largest_area(coordinates, size \\ 9) do
    plot = Day6.Grid.plot_distance(coordinates, size)

    ignored = ignored_labels(plot)

    plot
    |> List.flatten()
    |> Enum.reduce(%{}, fn label, acc ->
      Map.update(acc, label, 1, &(&1 + 1))
    end)
    |> Map.to_list()
    |> Enum.reject(fn {label, _} -> Enum.member?(ignored, label) end)
    |> List.keysort(1)
    |> List.last()
  end

  defp ignored_labels(plot) do
    plot
    |> border_labels()
    |> Enum.uniq()
  end

  defp border_labels(plot) do
    first_last(plot) ++ first_last(Matrix.transpose(plot))
  end

  defp first_last(plot) do
    List.first(plot) ++ List.last(plot)
  end

  def manhattan_sum(lookup, point) do
    Map.fetch!(lookup, point)
  end

  def safe_region_size(lookup, threshold) do
    lookup
    |> Enum.filter(fn {_point, sum} -> sum < threshold end)
    |> Enum.count()
  end
end

defmodule Day6.Grid do
  def plot(coordinates, size \\ 9) do
    labels = labels_for(coordinates)

    for y <- 0..size do
      for x <- 0..size do
        point = {x, y}
        if Enum.member?(coordinates, point), do: label_for(labels, point), else: "."
      end
    end
  end

  def plot_distance(coordinates, size \\ 9) do
    labels = labels_for(coordinates)

    for y <- 0..size do
      for x <- 0..size do
        point = {x, y}

        if Enum.member?(coordinates, point) do
          label_for(labels, point)
        else
          case closest_coordinate(coordinates, point) do
            [closest | []] ->
              label_for(labels, closest)

            _ ->
              "."
          end
        end
      end
    end
  end

  def manhattan_sums(coordinates, size \\ 9) do
    for y <- 0..size do
      for x <- 0..size do
        point = {x, y}

        {point, manhattan_sum(coordinates, point)}
      end
    end
  end

  def manhattan_sum(coordinates, point) do
    coordinates
    |> Enum.map(&manhattan(&1, point))
    |> Enum.sum()
  end

  def to_lookup(grid) do
    grid
    |> List.flatten()
    |> Map.new()
  end

  def label_grid(grid, labeller) do
    grid
    |> Enum.map(&label_row(&1, labeller))
  end

  def label_row(row, labeller) do
    row
    |> Enum.map(fn {point, value} ->
      labeller.(point, value)
    end)
  end

  def ascii_labeller(values) do
    # pixels = String.split(" .,:;i1tfLCG08@", "", trim: true)
    pixels = String.split(" .○☼•❄", "", trim: true)
    pixel_count = Enum.count(pixels)
    bins = make_bins(values, pixels)
    labeller = make_labeller(bins, pixels)

    pixel_for = fn value ->
      Enum.find(labeller, {:not_found, "?"}, fn {{low, high}, label} ->
        value >= low and value <= high
      end)
      |> elem(1)
    end

    fn _point, value ->
      pixel_for.(value)
    end
  end

  def make_labeller(bins, labels) do
    bins
    |> Enum.zip(labels)
    |> IO.inspect(label: "bins")
  end

  def make_bins(values, labels) do
    IO.puts(labels |> Enum.join())
    count = Enum.count(labels)
    values = Enum.sort(values)
    {min, max} = Enum.min_max(values)
    IO.inspect({min, max}, label: "range")
    rise = max - min
    run = Enum.count(values)
    IO.inspect(rise, label: "rise")
    IO.inspect(run, label: "run")

    slope =
      (rise / run)
      |> IO.inspect(label: "slope")

    # y - y1 = m(x - x1)
    x = 20
    y = slope * x + min
    IO.inspect(y, label: "y")

    uniq_values = Enum.uniq(values) |> Enum.sort()
    uniq_count = Enum.count(uniq_values)

    chunk_size =
      max(div(uniq_count, count), 1)
      |> IO.inspect(label: "chunk_size")

    keys =
      uniq_values
      |> Enum.chunk_every(chunk_size)
      |> Enum.map(fn chunk ->
        {List.first(chunk), List.last(chunk)}
      end)
      |> IO.inspect(label: "chunks", charlists: :as_lists)
  end

  def inspect(plot) do
    plot
    |> Enum.map(&Enum.join(&1))
    |> Enum.join("\n")
  end

  def label_for(labels, point), do: Map.fetch!(labels, point)

  def labels_for(coordinates) do
    letters =
      Stream.unfold(?A, fn letter ->
        {letter, letter + 1}
      end)

    coordinates
    |> Enum.zip(letters)
    |> Map.new(fn {point, label} -> {point, <<label>>} end)
  end

  def closest_coordinate(coordinates, point) do
    coordinates
    |> Enum.group_by(&manhattan(&1, point))
    |> Map.to_list()
    |> List.keysort(0)
    |> List.first()
    |> elem(1)
  end

  def manhattan({x1, y1}, {x2, y2}) do
    abs(x1 - x2) + abs(y1 - y2)
  end

  def extents(coordinates) do
    coordinates
    |> Enum.reduce(fn {x, y}, {xm, ym} ->
      {max(x, xm), max(y, ym)}
    end)
  end
end

defmodule Matrix do
  # Source: https://github.com/pmarreck/elixir-snippets/blob/master/matrix.exs
  # this crazy clever algorithm hails from
  # http://stackoverflow.com/questions/5389254/transposing-a-2-dimensional-matrix-in-erlang
  # and is apparently from the Haskell stdlib. I implicitly trust Haskellers.
  def transpose([[x | xs] | xss]) do
    [[x | for([h | _] <- xss, do: h)] | transpose([xs | for([_ | t] <- xss, do: t)])]
  end

  def transpose([[] | xss]), do: transpose(xss)
  def transpose([]), do: []
end

ExUnit.start(seed: 0, trace: true)

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

      assert {"E", 17} = Day6.largest_area(coordinates)
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

      grid = Day6.Grid.manhattan_sums(coordinates)
      lookup = Day6.Grid.to_lookup(grid)

      assert 30 = Day6.manhattan_sum(lookup, {4, 3})
      # assert 16 = Day6.safe_region_size(lookup, 32)

      IO.puts("\n")

      labeller =
        lookup
        |> Map.values()
        |> Day6.Grid.ascii_labeller()

      grid
      |> Day6.Grid.label_grid(labeller)
      |> Day6.Grid.inspect()
      |> IO.puts()
    end
  end

  describe "puzzle" do
    test "largest area" do
      coordinates =
        File.read!("day06.txt")
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
        File.read!("day06.txt")
        |> String.split("\n", trim: true)
        |> Enum.map(&parse_coordinate/1)

      grid = Day6.Grid.manhattan_sums(coordinates)
      lookup = Day6.Grid.to_lookup(grid)
      assert 16 == Day6.safe_region_size(lookup, 10_000)
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

  test "lookups" do
    lookup = [
      {{28, 30}, " "},
      {{32, 34}, "."},
      {{36, 38}, "○"},
      {{40, 42}, "☼"},
      {{44, 46}, "•"},
      {{48, 50}, "❄"}
    ]

    pixel_for = fn value ->
      Enum.find(lookup, {:not_found, "?"}, fn {{low, high}, label} ->
        value >= low and value <= high
      end)
    end

    assert {{32, 34}, "."} = pixel_for.(32)
    assert {{32, 34}, "."} = pixel_for.(33)
    assert {{32, 34}, "."} = pixel_for.(34)
    assert {{36, 38}, "○"} = pixel_for.(36)
    assert {:not_found, "?"} = pixel_for.(99)
  end
end
