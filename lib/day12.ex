defmodule Day12 do
  def answer(input, generation) do
    {state, rules} = parse(input)

    {sum, _gen} =
      state
      |> all_generations(rules)
      |> time_leap(generation)

    sum
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

  def time_leap(all_generations, target_generation) do
    case find_steady_state(all_generations, target_generation) do
      {:result, sum: sum, gen: gen} ->
        {sum, gen}

      {:steady, diff_per_gen: diff_per_gen, gen: gen, sum: sum} ->
        {sum + (target_generation - gen) * diff_per_gen, gen}
    end
  end

  def find_steady_state(all_generations, target_generation) do
    all_generations
    |> Stream.with_index()
    |> Stream.transform(
      %{count: 0, sum: 0, target: target_generation},
      &do_find_steady_state/2
    )
    |> Stream.take(-1)
    |> Enum.at(0)
  end

  defp do_find_steady_state({_pots, meta}, :halt), do: {:halt, meta}

  defp do_find_steady_state({pots, gen}, %{target: target}) when target == gen do
    sum = Enum.sum(pots)

    {[{:result, sum: sum, gen: gen}], :halt}
  end

  defp do_find_steady_state({pots, gen}, acc) when rem(gen, 100) == 0 do
    count = Enum.count(pots)
    sum = Enum.sum(pots)
    next_acc = Map.merge(acc, %{count: count, sum: sum, gen: gen})

    if steady_state?(pots, acc) do
      prev_sum = Map.get(acc, :sum)
      diff = sum - prev_sum
      diff_per_gen = div(diff, 100)

      {[{:steady, diff_per_gen: diff_per_gen, gen: gen, sum: sum}], :halt}
    else
      {[{pots, gen}], next_acc}
    end
  end

  defp do_find_steady_state({pots, gen}, acc) do
    {[{pots, gen}], acc}
  end

  def steady_state?(pots, %{count: prev_count}) do
    Enum.count(pots) == prev_count
  end

  def all_generations(state, rules) do
    rules = prepare_rules(rules)
    Stream.iterate(state, &next_gen(&1, rules))
  end

  def next_gen(state, rules) do
    state
    |> pot_stream()
    |> Enum.reduce([], fn {n, values}, acc ->
      case apply_rules(values, rules) do
        true -> [n | acc]
        false -> acc
        nil -> acc
      end
    end)
    |> Enum.reverse()
  end

  def get_values(state, neighbours) do
    neighbours
    |> Enum.map(fn n ->
      Enum.member?(state, n)
    end)
    |> List.to_tuple()
  end

  def pot_stream(source) do
    {left, right} = Enum.min_max(source)
    n = left - 2
    neighbours = [n - 2, n - 1, n, n + 1, n + 2]
    values = get_values(source, neighbours)

    Stream.unfold({values, source, n, right + 2}, &next_window/1)
  end

  defp next_window({_values, _source, n, last}) when n > last, do: nil

  defp next_window({values, source, n, last}) do
    next_n = n + 1
    next_pot = Enum.member?(source, next_n + 2)

    next_values =
      values
      |> Tuple.delete_at(0)
      |> Tuple.append(next_pot)

    {{n, values}, {next_values, source, next_n, last}}
  end

  def prepare_rules(rules) do
    Map.new(rules)
  end

  @compile {:inline, apply_rules: 2}
  def apply_rules(values, rules) do
    Map.get(rules, values)
  end

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
