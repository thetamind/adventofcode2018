defmodule Day12 do
  def answer(input, generation) do
    {state, rules} = parse(input)

    state
    |> run(rules)
    |> Enum.at(20)
  end

  def parse(input) do
    {state, rules} =
      input
      |> String.split("\n")
      |> Enum.reduce({nil, []}, fn line, {state, rules} ->
        case parse_line(line) do
          {:state, pots} -> {pots, rules}
          {:rule, rule} -> {state, [rule | rules]}
          nil -> {state, rules}
        end
      end)

    {state, Enum.reverse(rules)}
  end

  def parse_line(<<"initial state: ", input::binary>>) do
    pots =
      input
      |> String.split("", trim: true)
      |> Enum.with_index()
      |> Enum.reduce([], fn elem, acc ->
        case elem do
          {"#", index} -> [index | acc]
          {".", _} -> acc
        end
      end)

    {:state, Enum.reverse(pots)}
  end

  def parse_line(<<pattern::binary-size(5), " => ", present::binary-size(1)>>) do
    {:rule, {pattern, present}}
  end

  def parse_line(""), do: nil

  def run(state, rules) do
    [0, 1, 2, 3]
  end
end
