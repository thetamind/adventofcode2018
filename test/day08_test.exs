
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
