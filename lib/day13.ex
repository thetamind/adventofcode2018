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
    to_cart = fn {{x, y}, dir} -> {{x, y}, dir, :left} end

    %__MODULE__{frame: 0, map: map, carts: Enum.map(carts, to_cart)}
  end

  def all_ticks(%Simulation{} = state) do
    Stream.iterate(state, &next_tick/1)
  end

  def next_tick(%Simulation{map: map, carts: carts, frame: frame} = state) do
    next_frame = frame + 1

    tile_lookup = fn {x, y} -> Day13.TrackMap.get(map, {x, y}) end

    {next_carts, collisions} =
      carts
      |> sort_carts()
      |> move_carts()
      |> rotate_carts(tile_lookup)
      |> collisions

    %Simulation{state | frame: next_frame, carts: next_carts, collisions: collisions}
  end

  def sort_carts(carts) do
    Enum.sort_by(carts, fn {{x, y}, _, _} ->
      {y, x}
    end)
  end

  def move_carts(carts) do
    Enum.map(carts, &move_cart/1)
  end

  def move_cart({{x, y}, dir, next_turn}) do
    next_pos =
      case dir do
        :up -> {x, y - 1}
        :down -> {x, y + 1}
        :left -> {x - 1, y}
        :right -> {x + 1, y}
      end

    {next_pos, dir, next_turn}
  end

  def rotate_carts(carts, map) do
    Enum.map(carts, &rotate_cart(&1, map))
  end

  def rotate_cart({{x, y}, dir, next_turn}, tile_lookup) do
    tile = tile_lookup.({x, y})

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

    {next_dir, next_turn} =
      case tile do
        :intersection -> intersection_turn(dir, next_turn)
        _ -> {next_dir, next_turn}
      end

    {{x, y}, next_dir, next_turn}
  end

  defp intersection_turn(dir, turn) do
    next_dir =
      case turn do
        :left -> turn_left(dir)
        :straight -> dir
        :right -> turn_right(dir)
      end

    {next_dir, turn_sequence(turn)}
  end

  defp turn_sequence(turn) do
    case turn do
      :left -> :straight
      :straight -> :right
      :right -> :left
    end
  end

  defp turn_left(dir) do
    case dir do
      :up -> :left
      :down -> :right
      :left -> :down
      :right -> :up
    end
  end

  defp turn_right(dir) do
    case dir do
      :up -> :right
      :down -> :left
      :left -> :up
      :right -> :down
    end
  end

  def collisions(carts) do
    {carts, gather_collisions(carts)}
  end

  def gather_collisions(carts) do
    Enum.reduce(carts, {MapSet.new(), MapSet.new()}, fn {{x, y}, _dir, _}, {elems, dupes} ->
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
  @spec get(tuple(), {non_neg_integer, non_neg_integer()}) :: atom | :error
  def get(map, {x, y}) do
    with {:ok, row} <- safe_elem(map, y),
         {:ok, tile} <- safe_elem(row, x) do
      tile
    else
      :error -> :empty
    end
  end

  @compile {:inline, safe_elem: 2}
  defp safe_elem(tuple, index) when index < tuple_size(tuple), do: {:ok, elem(tuple, index)}
  defp safe_elem(_tuple, _index), do: :error

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
          {tile, cart_dir} -> {tile, [{{x, y}, cart_dir} | acc]}
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

  def symbol_to_char(symbol) do
    case symbol do
      :vertical -> ?|
      :horizontal -> ?-
      :curve_r -> ?/
      :curve_l -> ?\\
      :intersection -> ?+
      :collision -> ?X
      :cart_up -> ?^
      :cart_down -> ?v
      :cart_right -> ?>
      :cart_left -> ?<
      :up -> ?^
      :down -> ?v
      :right -> ?>
      :left -> ?<
      :empty -> ?\s
    end
  end
end

defmodule Day13.Inspect do
  alias Day13.{Simulation, TrackMap}

  def puts(%Simulation{} = state) do
    IO.puts(frame(state))
    IO.puts(ascii_map(state))

    state
  end

  def frame(%Simulation{} = state) do
    to_string(state.frame)
  end

  def ascii_map(%Simulation{map: map, carts: carts, collisions: collisions}) do
    ascii_map(map, carts, collisions)
  end

  def ascii_map(map, carts, collisions) do
    {width, height} = TrackMap.size(map)
    carts = Map.new(carts, fn {{x, y}, dir, _} -> {{x, y}, dir} end)
    collisions = MapSet.new(collisions)

    for y <- 0..(height - 1) do
      for x <- 0..(width - 1) do
        if MapSet.member?(collisions, {x, y}) do
          :collision
        else
          tile = TrackMap.get(map, {x, y})

          case Map.get(carts, {x, y}) do
            nil -> tile
            dir -> dir
          end
        end
        |> TrackMap.symbol_to_char()
      end
      |> to_string()
    end
    |> Enum.join("\n")
  end
end
