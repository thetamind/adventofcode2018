defmodule Day11 do
  def answer(opts) do
    opts
    |> grid()
    |> largest_power_square(size)
  end

  def answer_part2(opts) do
    opts
    |> grid()
    |> all_squares()
  end

  def grid(opts) do
    serial = Keyword.fetch!(opts, :serial)

    Map.new(all_coordinates(), fn {x, y} ->
      {{x, y}, cell_power(serial, {x, y})}
    end)
  end

  def all_coordinates() do
    for y <- 1..300, x <- 1..300, do: {x, y}
  end

  def all_squares() do
    for n <- 1..300, do: squares(size: n)
  end

  def squares(opts) do
    size = Keyword.fetch!(opts, :size)

    for y <- 1..(300 - size + 1), x <- 1..(300 - size + 1), do: {x, y}
  end

  def square_power(grid, {x, y}) do
    square_for(x, y)
    |> Enum.sum()
  end

  def square_for({left, top}, size) do
    right = left + size - 1
    bottom = top + size - 1

    for y <- top..bottom, x <- left..right, do: {x, y}
  end

  def cell_power(serial, {x, y}) do
    rack_id = x + 10
    power = rack_id * y
    power = power + serial
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
