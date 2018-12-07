defmodule Day02 do
  def checksum(ids) do
    counts =
      examine_ids(ids)
      |> Enum.reduce(%{twos: 0, threes: 0}, fn {twos, threes}, acc ->
        acc
        |> maybe_increment(:twos, twos)
        |> maybe_increment(:threes, threes)
      end)

    twos = Map.get(counts, :twos)
    threes = Map.get(counts, :threes)
    twos * threes
  end

  def examine_ids(ids) do
    Enum.map(ids, &examine_id/1)
  end

  def examine_id(id) do
    counts = counts(id)

    {
      has_value(counts, 2),
      has_value(counts, 3)
    }
  end

  def has_value(map, value) do
    case Enum.find(map, fn {_, v} -> v == value end) do
      {_, _} -> true
      nil -> false
    end
  end

  def counts(id) do
    String.graphemes(id)
    |> Enum.reduce(%{}, fn letter, acc ->
      Map.update(acc, letter, 1, &(&1 + 1))
    end)
  end

  def closest(target, ids) do
    Enum.reduce(ids, {0, nil}, fn id, {prev_score, _} = acc ->
      score = String.jaro_distance(target, id)

      if score > prev_score do
        {score, id}
      else
        acc
      end
    end)
  end

  def factoriadics(ids) do
    Enum.map(ids, fn id -> {id, Enum.reject(ids, &(id == &1))} end)
  end

  def correct_boxes(ids) do
    {a, b, _} =
      ids
      |> factoriadics()
      |> Enum.map(fn {target, ids} ->
        {score, id} = closest(target, ids)
        {target, id, score}
      end)
      |> Enum.sort_by(&elem(&1, 2), &>=/2)
      |> Enum.fetch!(0)

    {a, b}
  end

  def part2(ids) do
    {a, b} = correct_boxes(ids)
    common_letters(a, b)
  end

  def common_letters(a, b) do
    as = String.graphemes(a)
    bs = String.graphemes(b)

    diff = as -- bs
    (as -- diff) |> Enum.join()
  end

  def permutate(list) do
    list
    # Get a list of "shifts" of the given list, e.g. [1, 2, 3] should return [[1, 2, 3], [2, 3, 1], [3, 1, 2]]
    |> Enum.scan(list, fn _, [h | t] -> t ++ [h] end)
    # You can now recursively permutate the tail of each list, which will give us a tree-like structure of permutations
    |> Enum.map(fn [h | t] -> {h, t |> permutate} end)
    # Add the head to each child permutation, i.e. { 1, [[2, 3], [3, 2]] } should become [[1, 2, 3], [1, 3, 2]]
    # This collapses our tree-like structure into a list of permutations
    |> Enum.flat_map(fn {h, t} -> t |> Enum.map(&([h] ++ &1)) end)
  end

  defp maybe_increment(map, key, true), do: Map.update!(map, key, &(&1 + 1))
  defp maybe_increment(map, _key, false), do: map
end

# https://www.reddit.com/r/elixir/comments/74088r/how_can_i_improve_my_code_simple_permutation/dnutigb/
defmodule Permute do
  def all(list) when is_list(list) do
    permutations = factorial(list) - 1
    for n <- 0..permutations, do: nth(list, n)
  end

  def nth(list, index) when is_list(list) and is_integer(index) and index >= 0 do
    factoradic(index)
    |> (fn f -> List.duplicate(0, length(list) - length(f)) ++ f end).()
    |> Enum.reduce({list, []}, &reducer/2)
    |> (fn {_, permutated} -> permutated end).()
  end

  defp reducer(index, {input, acc}) do
    {value, remaining} = List.pop_at(input, index)
    {remaining, [value | acc]}
  end

  defp factorial(list) do
    Enum.reduce(1..length(list), 1, fn x, acc -> x * acc end)
  end

  def factoradic(i), do: factoradic(i, 2, [0])
  def factoradic(0, _step, acc), do: acc

  def factoradic(i, step, acc) do
    mod = Integer.mod(i, step)
    rem = Integer.floor_div(i, step)
    factoradic(rem, step + 1, [mod | acc])
  end
end

ExUnit.start()

defmodule Day02Test do
  use ExUnit.Case, async: true

  test "examples" do
    input = """
    abcdef
    bababc
    abbcde
    abcccd
    aabcdd
    abcdee
    ababab
    """

    assert {false, false} == Day02.examine_id("abcdef")
    assert {true, true} == Day02.examine_id("bababc")
    assert {true, false} == Day02.examine_id("abbcde")

    ids = String.split(input, "\n", trim: true)
    assert 7 == Day02.examine_ids(ids) |> Enum.count()
    assert 12 == Day02.checksum(ids)
  end

  test "puzzle" do
    ids =
      File.read!("day02.txt")
      |> String.split("\n", trim: true)

    assert 5434 == Day02.checksum(ids)
  end

  describe "part 2" do
    test "puzzle" do
      ids =
        File.read!("day02.txt")
        |> String.split("\n", trim: true)

      assert "agimdjvlhedpsyoqfzuknpjwt" == Day02.part2(ids)
    end

    test "examples" do
      input = """
      abcde
      fghij
      klmno
      pqrst
      fguij
      axcye
      wvxyz
      """

      ids = input |> String.split("\n", trim: true)

      assert {"fghij", "fguij"} == Day02.correct_boxes(ids)

      assert "fgij" == Day02.part2(ids)
    end

    test "closeness" do
      input = """
      abcde
      klmno
      pqrst
      fguij
      axcye
      wvxyz
      """

      ids = input |> String.split("\n", trim: true)

      assert {_, "fguij"} = Day02.closest("fghij", ids)
    end

    test "factoriadics" do
      ids = ~w(a b c d)s

      expected =
        %{
          "a" => ~w(b c d)s,
          "b" => ~w(a c d)s,
          "c" => ~w(a b d)s,
          "d" => ~w(a b c)s
        }
        |> Map.to_list()

      assert expected == Day02.factoriadics(ids)
    end
  end
end
