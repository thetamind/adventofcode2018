defmodule Day14 do
  def next_ten(num_rounds) do
    board = [3, 7]
    elves = [0, 1]

    combine(board, elves)
  end

  def combine(board, elves) do
    [idx1, idx2] = elves
    recipe1 = Enum.at(board, idx1)
    recipe2 = Enum.at(board, idx2)

    sum = recipe1 + recipe2
    new_recipes = Integer.digits(sum)

    next_board = board ++ new_recipes
    length = Enum.count(next_board)

    next_elves = [
      Integer.mod(idx1 + 1 + recipe1, length),
      Integer.mod(idx2 + 1 + recipe2, length)
    ]

    {next_board, next_elves}
  end
end
