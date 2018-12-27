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
  end
end
