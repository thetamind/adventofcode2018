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
      log =
        sample_input()
        |> Day7.parse()
        |> Day7.to_requirements()
        |> Day7b.new(workers: 2, base_duration: 0)
        |> Day7b.part2()

      duration =
        log
        |> List.last()
        |> Day7b.processing_time()

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

    test "part 2" do
      log =
        input()
        |> Day7.parse()
        |> Day7.to_requirements()
        |> Day7b.new(workers: 5, base_duration: 60)
        |> Day7b.part2()

      duration =
        log
        |> List.last()
        |> Day7b.processing_time()

      assert 864 == duration
    end

    def input() do
      File.read!("priv/day07.txt")
      |> String.trim_trailing("\n")
    end
  end
end
