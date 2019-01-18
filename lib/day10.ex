defmodule Day10 do
  def parse(input), do: Stream.map(input, &parse_line/1)

  def parse_line(line) do
    line
    |> String.split(["<", ">", ","])
    |> Enum.map(&String.trim/1)
    |> parts_to_points()
  end

  def parts_to_points([_, px, py, _, vx, vy | _]) do
    %{px: px, py: py, vx: vx, vy: vy}
    |> Enum.into(%{}, fn {k, v} -> {k, String.to_integer(v)} end)
  end

  def to_sky(points) do
    points
  end

  def light_at(sky, {x, y}) do
    Enum.any?(sky, fn %{px: px, py: py} ->
      px == x and py == y
    end)
  end

  def light_stream(sky) do
    Stream.iterate(sky, &move_lights/1)
  end

  def move_lights(sky) do
    Stream.map(sky, &move_light/1)
  end

  def move_light(%{px: px, py: py, vx: vx, vy: vy}) do
    %{px: px + vx, py: py + vy, vx: vx, vy: vy}
  end

  def print_sky(sky, extents) do
    points = MapSet.new(sky, fn %{px: px, py: py} -> {px, py} end)

    plot(points, extents)
    |> puts()
  end

  def puts(plot) do
    plot
    |> Enum.map(&Enum.join(&1))
    |> Enum.join("\n")
    |> IO.puts()
  end

  def plot(lights, {left, right, top, bottom}) do
    for y <- top..bottom do
      for x <- left..right do
        point = {x, y}
        if Enum.member?(lights, point), do: "#", else: "."
      end
    end
  end

  def extents(sky) do
    sky
    |> MapSet.new(fn %{px: px, py: py} -> {px, py} end)
    |> Enum.reduce({0, 0, 0, 0}, fn {x, y}, {xmin, xmax, ymin, ymax} ->
      {min(x, xmin), max(x, xmax), min(y, ymin), max(y, ymax)}
    end)
  end

  def magnitude ({left, right, top, bottom}) do
{right - left, top - bottom}
  end

  def find_message(light_stream) do
    light_stream
    |> Stream.with_index()
    |> Stream.each(fn {_, second} -> IO.puts("#{second}") end)
    |> Stream.filter(fn {sky, _second} ->
      Enum.all?(sky, fn %{px: px, py: py} ->
        px >= 0 and py >= 0
      end)
    end)
    |> Enum.take(1)
    |> Enum.at(0)
  end
end
