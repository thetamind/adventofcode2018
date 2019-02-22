defmodule Day14 do
  defstruct board: [3, 7], elves: [0, 1]

  alias __MODULE__

  #
  # target = round_stream |> Stream.at(num_rounds)
  # next_ten_recipes = round_stream(target) |> capture_next_ten
  def next_ten(num_rounds) do
    round_stream(%Day14{})
    |> Stream.take(num_rounds)
    |> Enum.to_list()
  end

  def round_at(round) do
    round_stream(%Day14{})
    |> Enum.at(round)
  end

  def round_stream(initial \\ %Day14{}) do
    Stream.iterate(initial, &next_round/1)
  end

  def next_round(%Day14{board: board, elves: elves} = state) do
    recipes =
      elves
      |> Enum.map(&Enum.at(board, &1))

    sum = Enum.sum(recipes)
    new_recipes = Integer.digits(sum)

    next_board = board ++ new_recipes
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

  @spec inspect_round(Day14.t()) :: any()
  def inspect_round(%Day14{board: board, elves: elves}) do
    pad = fn string -> String.pad_leading(string, 3) end

    decorate = fn
      score, 0 -> "(#{score})"
      score, 1 -> "[#{score}]"
    end

    elves_map = Enum.with_index(elves) |> Map.new()

    board
    |> Enum.with_index()
    |> Enum.reduce("", fn {score, board_index}, acc ->
      acc <>
        case Map.fetch(elves_map, board_index) do
          {:ok, elf_index} -> decorate.(score, elf_index) |> pad.()
          :error -> score |> to_string |> pad.()
        end
    end)
  end
end
