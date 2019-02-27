defmodule Day14.Vector do
  defstruct map: %{}, length: 0

  alias __MODULE__

  @type t :: %Vector{
          map: %{non_neg_integer => non_neg_integer},
          length: non_neg_integer
        }

  def new(values) do
    map =
      values
      |> Enum.with_index()
      |> Map.new(fn {v, idx} -> {idx, v} end)

    %Vector{map: map, length: Map.size(map)}
  end

  def append(%{map: map, length: length} = vector, more) do
    more_map =
      more
      |> Enum.with_index(length)
      |> Enum.map(fn {v, i} -> {i, v} end)
      |> Map.new()

    next_map = Map.merge(map, more_map)
    %{vector | map: next_map, length: length + Enum.count(more)}
  end

  def naïve_append(%{map: map} = vector, more) do
    max = Map.keys(map) |> Enum.max()

    source = Stream.iterate(max + 1, &(&1 + 1))

    more_map =
      source
      |> Enum.zip(more)
      |> Map.new()

    %{vector | map: Map.merge(map, more_map)}
  end

  def at(%{map: map}, index) do
    Map.get(map, index)
  end

  def fetch(%{map: map}, index) do
    Map.fetch(map, index)
  end

  def size(%{length: length}), do: length

  def to_list(%{map: map}) do
    Map.to_list(map)
  end

  def values(%{map: map}) do
    Map.values(map)
  end
end

defmodule Day14 do
  alias __MODULE__
  alias Day14.Vector

  defstruct board: Vector.new([3, 7]), elves: [0, 1]

  @type t() :: %Day14{
          board: Vector.t(),
          elves: [non_neg_integer]
        }

  def next_ten(num_recipes) do
    %{board: board} =
      round_stream()
      |> Stream.take_while(fn %{board: board} ->
        Vector.size(board) <= num_recipes + 15
      end)
      |> Enum.at(-1)

    board
    |> Vector.to_list()
    |> Enum.sort()
    |> Enum.drop(num_recipes)
    |> Enum.take(10)
    |> Keyword.values()
    |> Integer.undigits()
  end

  @spec round_at(non_neg_integer()) :: Day14.t()
  def round_at(round) do
    round_stream(%Day14{})
    |> Enum.at(round)
  end

  @spec round_stream(Day14.t()) :: Enumerable.t()
  def round_stream(initial \\ %Day14{}) do
    Stream.iterate(initial, &next_round/1)
  end

  @spec next_round(Day14.t()) :: Day14.t()
  def next_round(%Day14{board: board, elves: elves} = state) do
    recipes =
      elves
      |> Enum.map(&Vector.at(board, &1))

    sum = Enum.sum(recipes)
    new_recipes = Integer.digits(sum)

    next_board = Vector.append(board, new_recipes)
    length = Vector.size(next_board)

    next_elves =
      elves
      |> Enum.zip(recipes)
      |> Enum.map(&move_elf(&1, length))

    %Day14{state | board: next_board, elves: next_elves}
  end

  def move_elf({elf, recipe}, length) do
    Integer.mod(elf + 1 + recipe, length)
  end

  @spec inspect_round(Day14.t()) :: String.t()
  def inspect_round(%Day14{board: board, elves: elves}) do
    pad = fn string -> String.pad_leading(string, 3) end

    decorate = fn
      score, 0 -> "(#{score})"
      score, 1 -> "[#{score}]"
    end

    elves_map = Enum.with_index(elves) |> Map.new()

    board
    |> Vector.to_list()
    |> Enum.reduce("", fn {board_index, score}, acc ->
      acc <>
        case Map.fetch(elves_map, board_index) do
          {:ok, elf_index} -> decorate.(score, elf_index) |> pad.()
          :error -> score |> to_string |> pad.()
        end
    end)
  end

  @spec scoreboard(%{board: Vector.t()}) :: [{non_neg_integer, non_neg_integer}]
  def scoreboard(%{board: board}) do
    board
    |> Vector.to_list()
  end

  @spec scores(%{board: Vector.t()}) :: [non_neg_integer]
  def scores(%{board: board}) do
    board
    |> Vector.values()
  end
end
