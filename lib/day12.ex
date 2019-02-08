defmodule Day12 do
  def answer(input, generation) do
    {state, rules} = parse(input)

    state
    |> run(rules)
    |> Enum.at(20)
  end

  def parse(input) do
    state =
      input
      |> String.split("\n")
      |> Enum.reduce([], fn line, acc ->
        [parse_line(line) | acc]
      end)
      |> Enum.reverse()

    {state, []}
  end

  def parse_line(<<"initial state: ", pots::binary>>) do
    pots
    |> String.split("", trim: true)
  end

  def parse_line(<<pattern::binary-size(5), " => ", present::binary-size(1)>>) do
    {pattern, present}
  end

  def parse_line(""), do: nil

  def run(state, rules) do
    [0, 1, 2, 3]
  end
end
