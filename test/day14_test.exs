defmodule Day14Test do
  use ExUnit.Case, async: true

  @moduletag timeout: 20_000

  describe "next_ten/1" do
    test "returns scores of the next ten recipes" do
      assert 5_158_916_779 == Day14.next_ten(9)
      assert 0_124_515_891 == Day14.next_ten(5)
      assert 9_251_071_085 == Day14.next_ten(18)
      assert 5_941_429_882 == Day14.next_ten(2018)
    end

    test "puzzle" do
      assert 5_158_916_779 == Day14.next_ten(327_901)
    end
  end

  describe "round_stream/1" do
    test "at round number" do
      assert [3, 7, 1, 0] == Day14.round_at(1) |> Day14.scoreboard()

      expected = [3, 7, 1, 0, 1, 0, 1, 2, 4, 5, 1, 5, 8, 9]
      assert expected == Day14.round_at(10) |> Day14.scoreboard()
    end
  end

  describe "move_elf/2" do
    test "example" do
      assert 0 == Day14.move_elf({0, 3}, 4)
      assert 1 == Day14.move_elf({1, 7}, 4)
    end
  end

  describe "inspect_round/1" do
    test "first" do
      expected = ~S"""
      (3)[7]
      (3)[7] 1  0
       3  7  1 [0](1) 0
       3  7  1  0 [1] 0 (1)
      (3) 7  1  0  1  0 [1] 2
       3  7  1  0 (1) 0  1  2 [4]
       3  7  1 [0] 1  0 (1) 2  4  5
       3  7  1  0 [1] 0  1  2 (4) 5  1
       3 (7) 1  0  1  0 [1] 2  4  5  1  5
       3  7  1  0  1  0  1  2 [4](5) 1  5  8
       3 (7) 1  0  1  0  1  2  4  5  1  5  8 [9]
       3  7  1  0  1  0  1 [2] 4 (5) 1  5  8  9  1  6
       3  7  1  0  1  0  1  2  4  5 [1] 5  8  9  1 (6) 7
       3  7  1  0 (1) 0  1  2  4  5  1  5 [8] 9  1  6  7  7
       3  7 [1] 0  1  0 (1) 2  4  5  1  5  8  9  1  6  7  7  9
       3  7  1  0 [1] 0  1  2 (4) 5  1  5  8  9  1  6  7  7  9  2
      """

      actual =
        %Day14{}
        |> Day14.round_stream()
        |> Enum.take(16)
        |> Enum.map(&Day14.inspect_round/1)
        |> Enum.join("\n")

      anti_whitespace = &String.replace(&1, ~r/\s+/, "")

      assert anti_whitespace.(expected) == anti_whitespace.(actual)
    end
  end
end

defmodule Day14.VectorTest do
  use ExUnit.Case, async: true

  alias Day14.Vector

  describe "append/2" do
    test "adds sequential keys" do
      vector = Vector.new([:a, :b])
      result = Vector.append(vector, [:c, :d])

      assert [:a, :b, :c, :d] == Vector.values(result)
      assert {:ok, :c} == Vector.at(result, 2)
    end
  end

  describe "at/2" do
    test "present" do
      assert {:ok, 80} == Vector.at(large_vector(), 80)
    end

    test "absent" do
      assert :error == Vector.at(large_vector(), 1_000)
    end
  end

  describe "benchmark" do
    @describetag :bench
    @describetag timeout: 120_000

    test "append/2" do
      values = fn n ->
        Stream.cycle([0, 1, 2, 3, 4, 5, 6, 7, 8, 9])
        |> Enum.take(n)
      end

      inputs =
        [0, 1000, 10_000]
        |> JunkDrawer.selections(2)
        |> Map.new(fn [i, a] ->
          {"#{i}/#{a}", {i, values.(a), Vector.new(0..i)}}
        end)

      Benchee.run(
        %{
          "original" => fn {_i, a, vector} -> Vector.append(vector, a) end
        },
        time: 3,
        memory_time: 0,
        warmup: 0.5,
        inputs: inputs
      )
    end

    test ""
  end

  defp large_vector do
    0..20
    |> Vector.new()
    |> Vector.append(21..500)
  end
end
