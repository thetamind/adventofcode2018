defmodule Day7 do
  def parse(input) do
    input
    |> String.split("\n")
    |> Enum.map(&parse_line/1)
  end

  def parse_line(line) do
    parts = String.split(line, " ")

    [Enum.at(parts, 1), Enum.at(parts, 7)]
    |> List.to_tuple()
  end

  def to_requirements(instructions) do
    instructions
    |> Enum.group_by(&elem(&1, 1), &elem(&1, 0))
    |> fill_keys()
    |> Enum.to_list()
    |> Enum.map(fn {k, v} -> {k, Enum.sort(v)} end)
  end

  defp fill_keys(requirements) do
    requirements
    |> Map.values()
    |> List.flatten()
    |> Enum.uniq()
    |> Enum.reduce(requirements, &Map.put_new(&2, &1, []))
  end

  def order(requirements) do
    requirements
    |> Stream.unfold(&run/1)
    |> Enum.join()
  end

  def run(acc) do
    case next_step(acc) do
      nil -> nil
      step -> {step, remove_step(acc, step)}
    end
  end

  def next_step(requirements) do
    requirements
    |> Enum.find({nil, []}, &ready?/1)
    |> elem(0)
  end

  def remove_step(requirements, to_remove) do
    requirements
    |> Enum.map(fn {step, deps} ->
      {step, List.delete(deps, to_remove)}
    end)
    |> List.keydelete(to_remove, 0)
  end

  defp ready?({_step, []}), do: true
  defp ready?({_step, _deps}), do: false
end

defmodule Day7b do
  def processing_time(state) do
    state.time
  end

  def new(requirements, opts) do
    %{
      requirements: requirements,
      workers: Keyword.fetch!(opts, :workers),
      base_workers: Keyword.fetch!(opts, :workers),
      base_duration: Keyword.fetch!(opts, :base_duration),
      processing: %{},
      processed: [],
      time: 0
    }
  end

  # { req: [], workers: [], }
  # assign work
  ## available_work
  ## available_workers
  # cost = 60 + letter_cost
  # process_work
  # tick
  # leap to next boundary
  #
  def part2(state) do
    steps = next_steps(state)

    initial =
      Enum.reduce(steps, state, fn step, state ->
        assign_work(state, step)
      end)

    initial
    |> Stream.unfold(&run/1)
    |> Stream.each(&inspect_state/1)
    |> Enum.take(20)
  end

  def inspect_state(state) do
    workers =
      state.processing
      |> Map.keys()
      |> Stream.concat(Stream.cycle(["."]))
      |> Enum.take(state.base_workers)
      |> Enum.join("    ")

    done = state.processed |> Enum.join()

    if state.time == 0 do
      workers = Enum.map(1..state.base_workers, &"#{&1}") |> Enum.join("    ")
      header = "Second    #{workers}        Done"
      IO.puts(header)
    end

    log = "#{state.time}         #{workers}        #{done}"
    IO.puts(log)
  end

  # next_steps -> ["C", "A", "F"]
  # assign_work -> workers - 3, processing: %{"C" => 63, "A" => 61}
  # process_work -> loop tick -> processing: %{"C" => 63 - 1, "A" => 61 - 1}
  # tick -> time: time + 1
  # process_work when processing: %{"C" == 0} -> processing: remove C, processed: ["C" | rest]
  # cost("C", base_duration) -> base_duration + ?C - ?A + 1
  # leap -> processing.values.min
  # def run(%{processing: processing}) when map_size(processing) == 0, do: nil

  def run(acc) do
    steps = next_steps(acc)
    {acc, do_steps(acc, steps)}

    # |> IO.inspect()
  end

  def increment_time(state) do
    state
    |> Map.update!(:time, &(&1 + 1))
    |> update_in([:processing], &increment_processing_time/1)
  end

  defp increment_processing_time(processing) do
    Map.new(processing, fn {k, v} -> {k, v - 1} end)
  end

  def do_steps(state, steps) do
    state
    |> assign_work_steps(steps)
    |> increment_time()
    |> complete_work()
  end

  def assign_work_steps(state, steps) do
    Enum.reduce(steps, state, fn step, state ->
      assign_work(state, step)
    end)
  end

  def steps_done(processing) do
    # IO.inspect(processing, label: "steps_done")

    processing
    |> Enum.filter(fn {_step, remaining} -> remaining == 0 end)
    |> Enum.map(&elem(&1, 0))
  end

  def complete_work(state) do
    done = steps_done(state.processing)
    # IO.inspect(done, label: "complete_work")

    Enum.reduce(done, state, fn step, acc ->
      acc
      |> update_in([:requirements], &remove_step(&1, step))
      |> update_in([:processing], &Map.delete(&1, step))
    end)
    |> update_in([:workers], &(&1 + Enum.count(done)))
    |> update_in([:processed], &(&1 ++ done))
  end

  def remove_step(requirements, to_remove) do
    # IO.inspect(to_remove, label: "Removing")

    requirements
    |> Enum.map(fn {step, deps} ->
      {step, List.delete(deps, to_remove)}
    end)
    |> List.keydelete(to_remove, 0)
  end

  def assign_work(state, step) do
    cost = cost(step, state.base_duration)
    # IO.inspect(step, label: "Assigning")

    state
    |> update_in([:workers], &(&1 - 1))
    |> update_in([:processing], &Map.put_new(&1, step, cost))
    |> update_in([:requirements], &List.keydelete(&1, step, 0))
  end

  def next_steps(state) do
    state
    |> available_steps()
    |> Enum.take(state.workers)
  end

  def available_steps(state) do
    state.requirements
    |> Enum.filter(&ready?/1)
    |> Enum.map(&elem(&1, 0))
    # |> IO.inspect(label: "available")
  end

  defp cost(<<char>>, base) do
    base + char - ?A + 1
  end

  defp ready?({_step, []}), do: true
  defp ready?({_step, _deps}), do: false
end

ExUnit.start(seed: 0, trace: true)

defmodule Day7Test do
  use ExUnit.Case, async: true

  def sample_input do
    """
    Step C must be finished before step A can begin.
    Step C must be finished before step F can begin.
    Step A must be finished before step B can begin.
    Step A must be finished before step D can begin.
    Step B must be finished before step E can begin.
    Step D must be finished before step E can begin.
    Step F must be finished before step E can begin.
    """
    |> String.trim_trailing("\n")
  end

  describe "example" do
    test "parse" do
      expected = [
        {"C", "A"},
        {"C", "F"},
        {"A", "B"},
        {"A", "D"},
        {"B", "E"},
        {"D", "E"},
        {"F", "E"}
      ]

      assert expected == Day7.parse(sample_input())
    end

    test "to_requirements" do
      requirements =
        sample_input()
        |> Day7.parse()
        |> Day7.to_requirements()

      expected = [
        {"A", ["C"]},
        {"B", ["A"]},
        {"C", []},
        {"D", ["A"]},
        {"E", ["B", "D", "F"]},
        {"F", ["C"]}
      ]

      assert expected == requirements
    end

    test "order" do
      requirements =
        sample_input()
        |> Day7.parse()
        |> Day7.to_requirements()

      assert "CABDFE" == Day7.order(requirements)
    end

    test "part 2" do
      duration =
        sample_input()
        |> Day7.parse()
        |> Day7.to_requirements()
        |> Day7b.new(workers: 2, base_duration: 0)
        |> IO.inspect(label: "\n\n")
        |> Day7b.part2()

      # |> Day7b.processing_time()

      assert 15 == duration
    end
  end

  describe "puzzle" do
    test "order" do
      requirements =
        input()
        |> Day7.parse()
        |> Day7.to_requirements()

      assert "PFKQWJSVUXEMNIHGTYDOZACRLB" == Day7.order(requirements)
    end

    @tag skip: "soon"
    test "part 2" do
      duration =
        input()
        |> Day7.parse()
        |> Day7.to_requirements()
        |> Day7b.new(workers: 5, base_duration: 60)
        |> Day7b.part2()

      # |> Day7b.processing_time()

      assert 500 == duration
    end

    def input() do
      File.read!("day07.txt")
      |> String.trim_trailing("\n")
    end
  end
end
