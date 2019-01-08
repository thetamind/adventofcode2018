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
