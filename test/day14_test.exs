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
      assert %{board: [3, 7, 1, 0]} = Day14.round_at(1)

      expected = [3, 7, 1, 0, 1, 0, 1, 2, 4, 5, 1, 5, 8, 9]
      assert %{board: ^expected} = Day14.round_at(10)
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
