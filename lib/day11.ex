defmodule Day11 do
  def answer(opts) do
    {{x, y}, power} =
      opts
      |> grid()
      |> all_squares(3)
      |> Enum.max_by(fn {_, power} -> power end)

    {{x, y}, power}
  end

  def answer_part2(opts) do
    grid = grid(opts)

    1..20
    |> Enum.map(fn size ->
      IO.puts("#{size}")

      {{x, y}, power} =
        all_squares(grid, size)
        |> Enum.max_by(fn {_, power} -> power end)

      {{x, y}, size, power}
      |> IO.inspect()
    end)
    |> Enum.max_by(fn {_, _, power} -> power end)
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

  def all_squares(grid, size) do
    all_square_coordinates(size)
    |> Enum.map(fn {x, y} -> {{x, y}, square_power(grid, {x, y}, size)} end)
  end

  def all_square_coordinates(size) do
    for y <- 1..(300 - size + 1), x <- 1..(300 - size + 1), do: {x, y}
  end

  def square_power(grid, {x, y}, size) do
    square_for({x, y}, size)
    |> Enum.map(&Map.fetch!(grid, &1))
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
