defmodule Day13 do
end

defmodule Day13.TrackMap do
  def get(map, {x, y}) do
    elem(map, y)
    |> elem(x)
  end

  def parse(input) do
    input
    |> String.split("\n")
    |> Enum.map(&parse_line/1)
    |> Enum.reject(&(tuple_size(&1) == 0))
    |> List.to_tuple()
  end

  defp parse_line(line) do
    line
    |> String.to_charlist()
    |> Enum.map(&parse_symbol/1)
    |> List.to_tuple()
  end

  defp parse_symbol(char) do
    case char do
      ?| -> :vertical
      ?- -> :horizontal
      ?/ -> :curve_r
      ?\\ -> :curve_l
      ?+ -> :intersection
      ?^ -> :cart_up
      ?v -> :cart_down
      ?> -> :cart_right
      ?< -> :cart_left
      ?\s -> :empty
    end
  end
end
