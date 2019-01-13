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
end
