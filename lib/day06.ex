defmodule Day6 do
  def largest_area(coordinates, size) do
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
  def plot(coordinates, size) do
    labels = labels_for(coordinates)

    for y <- 0..size do
      for x <- 0..size do
        point = {x, y}
        if Enum.member?(coordinates, point), do: label_for(labels, point), else: "."
      end
    end
  end

  def plot_distance(coordinates, size) do
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

  def manhattan_sums(coordinates, size) do
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
    bins = make_bins(values, pixels)
    make_labeller(bins, pixels)
  end

  def pixel_for(labeller) do
    fn _point, value ->
      labeller
      |> Enum.reduce_while({0, "?"}, fn {min, label}, {last, last_label} ->
        cond do
          min == value -> {:halt, {min, label}}
          value > min -> {:cont, {min, label}}
          value < min -> {:halt, {last, last_label}}
        end
      end)
      |> elem(1)
    end
  end

  def make_labeller(bins, labels) do
    if Enum.count(bins) != Enum.count(labels) do
      IO.inspect(bins, label: "bins(#{Enum.count(bins)})")
      IO.inspect(labels, label: "labels(#{Enum.count(labels)})")
      raise "Not same length"
    end

    bins
    |> Enum.zip(labels)
    |> IO.inspect(label: "bins")
  end

  def step(min, max, step) do
    Enum.take_every(min..max, step)
  end

  def make_bins(values, labels) do
    {min, max} = Enum.min_max(values)

    step = div(max - min, Enum.count(labels)) + 1

    step(min, max, step)
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
