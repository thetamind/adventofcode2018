defmodule Day12 do
  def answer(input, generation) do
    {state, rules} = parse(input)

    state
    |> all_generations(rules)
    |> Enum.at(generation)
    |> IO.inspect(label: "gen #{generation}")
    |> Enum.sum()
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
    pattern =
      pattern
      |> String.split("", trim: true)
      |> Enum.map(fn code ->
        case code do
          "#" -> true
          "." -> false
        end
      end)
      |> List.to_tuple()

    present =
      case present do
        "#" -> true
        "." -> false
      end

    {:rule, {pattern, present}}
  end

  def parse_line(""), do: nil

  def all_generations(state, rules) do
    Stream.iterate(state, &next_gen(&1, rules))
    |> Stream.each(&inspect_state/1)
  end

  def next_gen(state, rules) do
    {left, right} = Enum.min_max(state)

    left..right
    |> Enum.map(fn n ->
      neighbours = [n - 2, n - 1, n, n + 1, n + 2]
      values = get_values(state, neighbours)

      case apply_rules(values, rules) do
        true -> n
        false -> nil
        nil -> nil
      end
    end)
    |> Enum.reject(&(&1 == nil))
    |> IO.inspect(label: "applied")
  end

  def get_values(state, neighbours) do
    neighbours
    |> Enum.map(fn n ->
      Enum.member?(state, n)
    end)
    |> List.to_tuple()
  end

  def apply_rules(values, rules) do
    rules
    |> Enum.reduce_while(rules, fn rule, _acc ->
      case apply_rule(values, rule) do
        {:match, present} -> {:halt, present}
        nil -> {:cont, nil}
      end
    end)
  end

  def apply_rule(values, {pattern, present}) when values == pattern, do: {:match, present}
  def apply_rule(_values, {_pattern, _present}), do: nil

  require Logger

  def inspect_state([]) do
    IO.puts("<<  empty state  >>")
  end

  def inspect_state(state) do
    {left, right} = Enum.min_max(state)

    msg =
      (left - 2)..(right + 2)
      |> Enum.map(fn n ->
        if Enum.any?(state, fn x -> x == n end), do: "#", else: "."
      end)
      |> Enum.join()

    IO.puts(msg)
  end
end
