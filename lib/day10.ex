defmodule Day10 do
  def parse(input), do: Enum.map(input, &parse_line/1)

  def parse_line(line) do
    line
    |> String.split(["<", ">", ","])
    |> Enum.map(&String.trim/1)
    |> parts_to_points()
  end

  @spec parts_to_points(nonempty_list()) :: {integer, integer, integer, integer}
  def parts_to_points([_, px, py, _, vx, vy | _]) do
    {
      String.to_integer(px),
      String.to_integer(py),
      String.to_integer(vx),
      String.to_integer(vy)
    }
  end

  def to_sky(points) do
    points
  end

  def light_at(sky, {x, y}) do
    Enum.any?(sky, fn {px, py, _, _} ->
      px == x and py == y
    end)
  end

  def light_stream(sky) do
    Stream.iterate(sky, &move_lights/1)
  end

  def move_lights(sky) do
    Enum.map(sky, &move_light/1)
  end

  def move_light({px, py, vx, vy}) do
    {px + vx, py + vy, vx, vy}
  end

  def move_light({px, py, vx, vy}, seconds) do
    {px + vx * seconds, py + vy * seconds, vx, vy}
  end

  def print_sky(sky, extents) do
    points = MapSet.new(sky, fn {px, py, _, _} -> {px, py} end)

    plot(points, extents)
    |> puts()
  end

  def puts(plot) do
    plot
    |> Enum.map(&Enum.join(&1))
    |> Enum.join("\n")
    |> IO.puts()
  end

  # extents: {-49919, 50232, -49910, 50189}
  # {50_170, 50_200, -29_880, -29_910}

  require Logger

  def plot(lights, {left, right, top, bottom}) do
    # Logger.debug(inspect(lights))

    for y <- top..bottom do
      for x <- left..right do
        point = {x, y}
        if Enum.member?(lights, point), do: "#", else: "."
      end
    end
  end

  def extents(sky) do
    {x, y, _, _} = List.first(sky)

    sky
    |> MapSet.new(fn {px, py, _, _} -> {px, py} end)
    |> Enum.reduce({x, x, y, y}, fn {x, y}, {xmin, xmax, ymin, ymax} ->
      {min(x, xmin), max(x, xmax), min(y, ymin), max(y, ymax)}
    end)
  end

  def dimensions({left, right, top, bottom}) do
    {right - left, bottom - top}
  end

  def magnitude(nil), do: :infinity

  def magnitude({left, right, top, bottom}) do
    (right - left) * (bottom - top)
  end

  def find_message_zero_origin(light_stream) do
    light_stream
    |> Stream.with_index()
    |> Stream.each(fn {_, second} -> IO.puts("#{second}") end)
    |> Stream.filter(fn {sky, _second} ->
      Enum.all?(sky, fn {px, py, _, _} ->
        px >= 0 and py >= 0
      end)
    end)
    |> Enum.take(1)
    |> Enum.at(0)
  end

  def find_message_vertical(light_stream) do
    light_stream
    |> Stream.with_index()
    |> Stream.map(fn {sky, second} ->
      score = score_vertical(sky)
      if rem(second, 100) == 0, do: Logger.debug("[#{second}] score: #{score}")
      {sky, second, score}
    end)
    |> Enum.reduce_while({nil, -1, 0}, fn {_sky, _second, score} = current, prev ->
      {_, _, prev_score} = prev

      if score >= prev_score do
        {:cont, current}
      else
        {:halt, prev}
      end
    end)
  end

  def find_message_extents(light_stream) do
    light_stream
    |> Stream.with_index()
    |> Stream.map(fn {sky, second} ->
      extents = extents(sky)

      {sky, second, extents}
    end)
    |> Enum.reduce_while({nil, -1, nil}, fn {_sky, second, extents} = current, prev ->
      {_, _, prev_extents} = prev
      expanding? = magnitude(extents) > magnitude(prev_extents)

      if rem(second, 100) == 0,
        do: Logger.debug("[#{second}] magnitude: #{magnitude(extents)} #{expanding?}")

      if second > 1_000 and second <= 1_020,
        do: Logger.debug("[#{second}] magnitude: #{magnitude(extents)} #{expanding?}")

      if expanding? or second > 1_100 do
        {:halt, prev}
      else
        {:cont, current}
      end
    end)
  end

  def sky_at(sky, second) do
    Enum.map(sky, &move_light(&1, second))
  end

  def meta_sky(sky, second) do
    sky = sky_at(sky, second)
    extents = extents(sky)
    dimensions = dimensions(extents)
    magnitude = magnitude(extents)

    %{sky: sky, second: second, extents: extents, dimensions: dimensions, magnitude: magnitude}
  end

  def describe_sky(%{
        second: second,
        extents: extents,
        dimensions: dimensions,
        magnitude: magnitude
      }) do
    pad = fn x -> String.pad_leading(to_string(x), 7) end
    look = fn x -> String.pad_leading(inspect(x), 18) end

    "[#{pad.(second)}]\t#{look.(extents)}\tdim: #{look.(dimensions)}\tmag: #{pad.(magnitude)}"
  end

  def time_travel() do
    puzzle =
      File.stream!("priv/day10.txt")
      |> Day10.parse()
      |> Enum.to_list()

    Stream.iterate(1, &(&1 + 1_000))
    |> Stream.map(fn second ->
      Logger.debug(fn -> describe_sky(meta_sky(puzzle, second)) end)
    end)
    |> Stream.take(15)
    |> Stream.run()
  end

  def jump_answer() do
    puzzle =
      File.stream!("priv/day10.txt")
      |> Day10.parse()
      |> Enum.to_list()

    # {sky, second, extents} =
    puzzle
    |> Day10.find_message_search()
  end

  def answer() do
    puzzle =
      File.stream!("priv/day10.txt")
      |> Day10.parse()
      |> Enum.to_list()

    # {sky, second, extents} =
    puzzle
    |> Day10.light_stream()
    |> Day10.find_message_extents()
  end

  def score_vertical(sky) do
    groups =
      sky
      |> Enum.reduce(%{}, fn {px, py, _, _}, acc ->
        Map.update(acc, px, [1], &[py | &1])
      end)

    Enum.reduce(groups, 0, fn {_, pys}, acc ->
      count = Enum.count(pys)

      if count >= 5 do
        acc + count
      else
        acc
      end
    end)
  end

  def score_vertical_reduce(sky) do
    groups =
      sky
      |> Enum.reduce(%{}, fn {px, _, _, _}, acc ->
        Map.update(acc, px, 1, &(&1 + 1))
      end)
      |> Enum.filter(fn {_x, count} -> count >= 5 end)

    groups
    |> Enum.map(fn {_, count} -> count end)
    |> Enum.sum()
  end

  def score_vertical_group_by(sky) do
    groups =
      sky
      |> Enum.group_by(fn {px, _, _, _} -> px end, fn _ -> [] end)
      |> Enum.map(fn {x, lights} -> {x, Enum.count(lights)} end)
      |> Enum.filter(fn {_x, count} -> count >= 5 end)

    # pad = fn s -> String.pad_leading(to_string(s), 5) end

    # Logger.debug(fn ->
    #   Enum.map(groups, fn {x, count} -> "#{pad.(x)}=>#{count}" end)
    #   |> Enum.join("  ")
    # end)

    groups
    |> Enum.map(fn {_, count} -> count end)
    |> Enum.sum()
  end
end
