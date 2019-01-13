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
end
