defmodule Day03Test do
  use ExUnit.Case, async: true

  alias Day03.{Claim, Fabric}

  describe "claim" do
    test "squares" do
      claim = %Claim{id: 1, left: 0, top: 0, width: 2, height: 3}
      expected = [{0, 0}, {1, 0}, {0, 1}, {1, 1}, {0, 2}, {1, 2}]
      assert expected == Claim.squares(claim)
    end
  end

  describe "fabric" do
    test "allocate squares" do
      claim1 = %Claim{id: 1, left: 1, top: 3, width: 4, height: 4}
      claim2 = %Claim{id: 2, left: 3, top: 1, width: 4, height: 4}

      fabric = %Fabric{}
      fabric = Fabric.add_claim(fabric, claim1)
      assert [1] == Fabric.at(fabric, 1, 3)
      assert [1] == Fabric.at(fabric, 3, 3)

      fabric = Fabric.add_claim(fabric, claim2)
      assert [1, 2] == Fabric.at(fabric, 3, 3)
    end
  end

  describe "day 3" do
    test "parse input to claims" do
      claims = Day03.parse_input(example_input())
      claim = Enum.at(claims, 0)

      assert %Claim{id: 1, left: 1, top: 3, width: 4, height: 4} = claim
    end

    test "example overlapping count" do
      claims = Day03.parse_input(example_input())
      fabric = Fabric.new(claims)
      assert 4 == Fabric.overlapping_count(fabric)
    end

    test "puzzle overlapping count" do
      claims = Day03.parse_input(puzzle_input())
      fabric = Fabric.new(claims)
      assert 109_716 == Fabric.overlapping_count(fabric)
    end

    test "example isolated claim" do
      claims = Day03.parse_input(example_input())
      fabric = Fabric.new(claims)
      assert 3 == Fabric.isolated_claim(fabric)
    end

    test "puzzle isolated claim" do
      claims = Day03.parse_input(puzzle_input())
      fabric = Fabric.new(claims)
      assert 124 == Fabric.isolated_claim(fabric)
    end

    defp example_input() do
      """
      #1 @ 1,3: 4x4
      #2 @ 3,1: 4x4
      #3 @ 5,5: 2x2
      """
      |> String.split("\n", trim: true)
    end

    defp puzzle_input() do
      File.read!("priv/day03.txt")
      |> String.split("\n", trim: true)
    end
  end
end
