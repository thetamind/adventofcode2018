defmodule Day13 do
end

defmodule Day13.TrackMap do
  def get(map, {x, y}) do
    elem(map, y)
    |> elem(x)
  end

  def parse(input) do
    {map, carts} =
      input
      |> tokenize()
      |> parse_carts()

    {tuplize(map), carts}
  end

  defp tuplize(list) do
    list
    |> Enum.map(&List.to_tuple/1)
    |> List.to_tuple()
  end

  def parse_carts(map) do
    {grid, carts} =
      map
      |> Enum.with_index()
      |> Enum.map_reduce([], fn {row, y}, acc ->
        {row, carts} = extract_carts(row, y)
        {row, [carts | acc]}
      end)

    carts = carts |> Enum.reverse() |> List.flatten()

    {grid, carts}
  end

  defp extract_carts(row, y) do
    {row, carts} =
      row
      |> Enum.with_index()
      |> Enum.map_reduce([], fn {tile, x}, acc ->
        case extract_cart(tile) do
          {tile, cart} -> {tile, [{{x, y}, cart} | acc]}
          tile -> {tile, acc}
        end
      end)

    {row, Enum.reverse(carts)}
  end

  def extract_cart(tile) do
    case tile do
      :cart_up -> {:vertical, :up}
      :cart_down -> {:vertical, :down}
      :cart_right -> {:horizontal, :right}
      :cart_left -> {:horizontal, :left}
      symbol -> symbol
    end
  end

  def tokenize(input) do
    input
    |> String.split("\n")
    |> Enum.map(&parse_line/1)
    |> Enum.reject(&Enum.empty?(&1))
  end

  defp parse_line(line) do
    line
    |> String.to_charlist()
    |> Enum.map(&parse_symbol/1)
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
