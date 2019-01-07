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
    Enum.reduce(children, Enum.max(meta), fn child, acc ->
      max(acc, meta_maximum(child))
    end)
  end

  def meta_sum(%__MODULE__{children: children, meta: meta}) do
    Enum.reduce(children, Enum.sum(meta), fn child, acc ->
      acc + meta_sum(child)
    end)
  end

  def check2(%__MODULE__{children: [], meta: meta}) do
    Enum.sum(meta)
  end

  def check2(%__MODULE__{children: children, meta: meta}) do
    Enum.reduce(meta, 0, fn idx, acc ->
      case Enum.at(children, idx - 1) do
        nil -> acc
        child -> acc + check2(child)
      end
    end)
  end

  def equal?(%__MODULE__{} = left, %__MODULE__{} = right) do
    left === right
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
    {tree, _} = read_tree(data)
    tree
  end

  def read_tree([child_count | [meta_count | tail]]) do
    {children, rest} = read_children(tail, child_count)
    {meta, rest} = read_metadata(rest, meta_count)

    {Node.new(children, meta), rest}
  end

  def read_children(input, 0) do
    {[], input}
  end

  def read_children(input, count) do
    Enum.reduce(0..(count - 1), {[], input}, fn _, {children, input} ->
      {node, input} = read_tree(input)
      {children ++ [node], input}
    end)
  end

  def read_metadata(input, count) do
    {meta, rest} = Enum.split(input, count)

    {meta, rest}
  end
end

ExUnit.start(seed: 0, trace: true)

defmodule Day8.NodeTest do
  use ExUnit.Case, async: true

  alias Day8.Node

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

  test "meta_sum" do
    assert 138 == Node.meta_sum(sample_tree())
  end

  test "equal?" do
    refute Node.equal?(sample_tree(), little_tree())
    assert Node.equal?(sample_tree(), sample_tree())
  end

  def little_tree do
    Node.new(
      [
        Node.new([], [5, 10])
      ],
      [3, 2, 1]
    )
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

  alias Day8.Node

  describe "part 1" do
    test "to_tree" do
      data = Day8.parse(sample_input())
      tree = Day8.to_tree(data)
      assert sample_tree() == tree
    end

    test "metadata sum" do
      data = Day8.parse(sample_input())
      tree = Day8.to_tree(data)
      assert 138 == Day8.Node.meta_sum(tree)
    end

    test "puzzle metadata sum" do
      data = Day8.parse(puzzle_input())
      tree = Day8.to_tree(data)
      assert 45_865 == Day8.Node.meta_sum(tree)
    end
  end

  describe "part 2" do
    test "sample" do
      data = Day8.parse(sample_input())
      tree = Day8.to_tree(data)
      assert 66 == Day8.Node.check2(tree)
    end

    test "puzzle" do
      data = Day8.parse(puzzle_input())
      tree = Day8.to_tree(data)
      assert 22_608 == Day8.Node.check2(tree)
    end
  end

  def sample_input do
    "2 3 0 3 10 11 12 1 1 0 1 99 2 1 1 2"
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

  def puzzle_input do
    File.read!("day08.txt")
    |> String.trim_trailing("\n")
  end
end
