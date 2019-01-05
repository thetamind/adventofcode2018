defmodule Day8 do
  def parse(input) do
    input
    |> String.split()
    |> Enum.map(&String.to_integer/1)
  end

  def to_tree(data) do

  end

  def meta_sum(tree) do
    0
  end
end

ExUnit.start(seed: 0, trace: true)

defmodule Day08Test do
  use ExUnit.Case, async: true

  describe "part 1" do
    test "metadata sum" do
      data = Day8.parse(sample_input())
      tree = Day8.to_tree(data)
      assert 138 == Day8.meta_sum(tree)
    end

    test "root"
  end

  def sample_input do
    "2 3 0 3 10 11 12 1 1 0 1 99 2 1 1 2"
  end

  def puzzle_input do
    File.read!("day08.txt")
    |> String.trim_trailing("\n")
  end
end
