defmodule Day11 do
  def answer(opts) do
    grid = grid(opts)
    {{0, 0}, 0}
  end

  def grid(opts) do
    serial = Keyword.fetch!(opts, :serial)
    %{serial: serial}
  end

  def cell_power(grid, {x, y}) do
    rack_id = x + 10
    power = rack_id * y
    power = power + grid.serial
    power = power * rack_id
    third_digit(power) - 5
  end

  def third_digit(number) do
    Integer.to_string(number)
    |> String.graphemes()
    |> Enum.reverse()
    |> Enum.at(2, "0")
    |> String.to_integer()
  end
end
