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

  defp maybe_increment(map, key, true), do: Map.update!(map, key, &(&1 + 1))
  defp maybe_increment(map, _key, false), do: map
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
end
