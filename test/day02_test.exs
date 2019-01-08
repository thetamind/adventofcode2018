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
      File.read!("priv/day02.txt")
      |> String.split("\n", trim: true)

    assert 5434 == Day02.checksum(ids)
  end

  describe "part 2" do
    test "puzzle" do
      ids =
        File.read!("priv/day02.txt")
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
