defmodule Day11 do
  def answer(opts) do
    opts
    |> grid()
    |> all_squares()
    |> Enum.max_by(fn {_, power} -> power end)
  end

  def grid(opts) do
    serial = Keyword.fetch!(opts, :serial)
    %{serial: serial}
  end

  def all_squares(grid) do
    Map.new(all_square_coordinates(), fn {x, y} ->
      {{x, y}, square_power(grid, {x, y})}
    end)
  end

  def all_square_coordinates() do
    for y <- 1..(300 - 2), x <- 1..(300 - 2), do: {x, y}
  end

  def square_power(grid, {x, y}) do
    square_for(x, y)
    |> Enum.map(&cell_power(grid, &1))
    |> Enum.sum()
  end

  def square_for(left, top) do
    right = left + 2
    bottom = top + 2

    for y <- top..bottom, x <- left..right, do: {x, y}
  end

  def cell_power(grid, {x, y}) do
    rack_id = x + 10
    power = rack_id * y
    power = power + grid.serial
    power = power * rack_id
    third_digit(power) - 5
  end

  def third_digit(number) do
    number
    |> Integer.digits()
    |> Enum.reverse()
    |> Enum.at(2, 0)
  end
end
