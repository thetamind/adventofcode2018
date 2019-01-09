defmodule Day9 do
  alias __MODULE__.Circle
end

defmodule Day9.Circle do
  @moduledoc """
  Source: https://github.com/sasa1977/aoc/blob/master/lib/2018/day9.ex
  """
  @type element :: non_neg_integer
  @opaque t :: {[element()], [element()]}

  @spec new([element]) :: t
  def new(elements), do: {elements, []}

  @spec next(t) :: t
  def next({[], prev}), do: next({Enum.reverse(prev), []})
  def next({[current | rest], prev}), do: {rest, [current | prev]}

  @spec prev(t) :: t
  def prev({next, []}), do: prev({[], Enum.reverse(next)})
  def prev({next, [last | rest]}), do: {[last | next], rest}

  @spec insert(t, element) :: t
  def insert({next, prev}, element), do: {[element | next], prev}

  @spec pop(t) :: {element, t}
  def pop({[], prev}), do: pop({Enum.reverse(prev), []})
  def pop({[current | rest], prev}), do: {current, {rest, prev}}
end
