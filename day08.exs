defmodule Day8.Node do
  defstruct children: [], meta: []

  def new(children, meta) when is_list(children) and is_list(meta) do
    %__MODULE__{children: children, meta: meta}
  end

  def child(tree, index) do
    Enum.at(tree.children, index)
  end

  def meta(tree) do
    tree.meta
  end

  def tree_size([]), do: 1

  def tree_size(%__MODULE__{children: children}) do
    Enum.reduce(children, 1, fn child, acc ->
      acc + tree_size(child)
    end)
  end

  def meta_maximum(%__MODULE__{children: children, meta: meta}) do
    max_children =
      Enum.reduce(children, 0, fn child, acc ->
        max(acc, meta_maximum(child))
      end)

    max(max_children, Enum.max(meta))
  end
end

defmodule Day8 do
  alias Day8.Node

  def parse(input) do
    input
    |> String.split()
    |> Enum.map(&String.to_integer/1)
  end

  def to_tree(data) do
    tree(data)
  end

  def tree([child_count | [meta_count | tail]]) do
    children = 0..child_count |> Enum.map(fn i -> Node.new([], [i]) end)
    meta = 0..meta_count |> Enum.to_list()
    Node.new(children, meta)
  end

  def meta_sum(tree) do
    tree
  end
end

ExUnit.start(seed: 0, trace: true)

defmodule Day8.NodeTest do
  use ExUnit.Case, async: true

  alias Day8.Node

  describe "new" do
    test "children" do
      meta =
        sample_tree()
        |> Node.child(1)
        |> Node.child(0)
        |> Node.meta()

      assert [99] == meta
    end

    test "tree_size" do
      assert 4 == Node.tree_size(sample_tree())
    end

    test "meta_maximum" do
      assert 99 == Node.meta_maximum(sample_tree())
    end
  end

  def sample_tree do
    Node.new(
      [
        Node.new([], [10, 11, 12]),
        Node.new(
          [
            Node.new([], [99])
          ],
          [2]
        )
      ],
      [1, 1, 2]
    )
  end
end

defmodule Day8Test do
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
