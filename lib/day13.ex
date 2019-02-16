defmodule Day13 do
  alias Day13.Simulation

  def first_crash(simulation) do
    simulation
    |> Simulation.all_ticks()
    |> Stream.take(20)
    |> Enum.find(&crash?/1)
  end

  defp crash?(sim) do
    length(sim.collisions) > 0
  end
end

defmodule Day13.Simulation do
  defstruct frame: 0, map: nil, carts: [], collisions: []

  alias __MODULE__

  def new(map, carts) do
    %__MODULE__{frame: 0, map: map, carts: carts}
  end

  def all_ticks(%Simulation{} = state) do
    Stream.iterate(state, &next_tick/1)
  end

  def next_tick(%Simulation{map: map, carts: carts, frame: frame} = state) do
    next_frame = frame + 1

    {next_carts, collisions} =
      carts
      |> sort_carts()
      |> move_carts()
      |> rotate_carts(map)
      |> collisions

    %Simulation{state | frame: next_frame, carts: next_carts, collisions: collisions}
  end

  def sort_carts(carts) do
    Enum.sort_by(carts, fn {{x, y}, _dir} -> {y, x} end)
  end

  def move_carts(carts) do
    Enum.map(carts, &move_cart/1)
  end

  def move_cart({{x, y}, dir}) do
    case dir do
      :up -> {{x, y - 1}, dir}
      :down -> {{x, y + 1}, dir}
      :left -> {{x - 1, y}, dir}
      :right -> {{x + 1, y}, dir}
    end
  end

  def rotate_carts(carts, map) do
    Enum.map(carts, &rotate_cart(&1, map))
  end

  def rotate_cart({{x, y}, dir}, map) do
    tile = Day13.TrackMap.get(map, {x, y})

    next_dir =
      case {dir, tile} do
        {:up, :curve_r} -> :right
        {:down, :curve_r} -> :left
        {:left, :curve_r} -> :down
        {:right, :curve_r} -> :up
        {:up, :curve_l} -> :left
        {:down, :curve_l} -> :right
        {:left, :curve_l} -> :up
        {:right, :curve_l} -> :down
        _ -> dir
      end

    {{x, y}, next_dir}
  end

  def collisions(carts) do
    {carts, gather_collisions(carts)}
  end

  def gather_collisions(carts) do
    Enum.reduce(carts, {MapSet.new(), MapSet.new()}, fn {{x, y}, _dir}, {elems, dupes} ->
      case MapSet.member?(elems, {x, y}) do
        true -> {elems, MapSet.put(dupes, {x, y})}
        false -> {MapSet.put(elems, {x, y}), dupes}
      end
    end)
    |> elem(1)
    |> MapSet.to_list()
  end
end

defmodule Day13.TrackMap do
  def get(map, {x, y}) do
    elem(map, y)
    |> elem(x)
  end

  def size(map) do
    width =
      map
      |> Tuple.to_list()
      |> Enum.max_by(&tuple_size(&1))
      |> tuple_size()

    height = tuple_size(map)

    {width, height}
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
