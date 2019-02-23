defmodule Day14 do
  alias __MODULE__
  defstruct board: %{0 => 3, 1 => 7}, elves: [0, 1]

  @type t() :: %Day14{
          board: %{non_neg_integer => non_neg_integer},
          elves: [non_neg_integer]
        }

  def next_ten(num_recipes) do
    %{board: board} =
      round_stream()
      |> Stream.take_while(fn %{board: board} ->
        Enum.count(board) <= num_recipes + 15
      end)
      |> Enum.at(-1)

    board
    |> Map.to_list()
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
      |> Enum.map(&Map.get(board, &1))

    sum = Enum.sum(recipes)
    new_recipes = Integer.digits(sum)

    next_board = append_vector(board, new_recipes)
    length = Enum.count(next_board)

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
    |> Enum.reduce("", fn {board_index, score}, acc ->
      acc <>
        case Map.fetch(elves_map, board_index) do
          {:ok, elf_index} -> decorate.(score, elf_index) |> pad.()
          :error -> score |> to_string |> pad.()
        end
    end)
  end

  @spec scoreboard(%{board: map()}) :: [non_neg_integer]
  def scoreboard(%{board: board}) do
    board
    |> Map.to_list()
    |> Enum.sort()
    |> Keyword.values()
  end

  def append_vector(map, more) do
    max = Map.keys(map) |> Enum.max()

    source = Stream.iterate(max + 1, &(&1 + 1))

    more_map =
      source
      |> Enum.zip(more)
      |> Map.new()

    Map.merge(map, more_map)
  end
end
