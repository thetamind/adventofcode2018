defmodule Day03 do
  defmodule Claim do
    defstruct [:id, :left, :top, :width, :height]

    @type t :: %Claim{
            id: non_neg_integer,
            left: non_neg_integer,
            top: non_neg_integer,
            width: non_neg_integer,
            height: non_neg_integer
          }

    def squares(%Claim{left: left, top: top, width: width, height: height}) do
      right = left + width - 1
      bottom = top + height - 1

      for y <- top..bottom, x <- left..right, do: {x, y}
    end
  end

  defmodule Fabric do
    defstruct allocations: %{}

    @opaque t :: %Fabric{
              allocations: map
            }

    def add_claim(%Fabric{allocations: allocations} = fabric, claim) do
      allocations =
        claim
        |> Claim.squares()
        |> Enum.reduce(allocations, fn key, acc ->
          Map.update(acc, key, [claim.id], &(&1 ++ [claim.id]))
        end)

      %{fabric | :allocations => allocations}
    end

    def at(%Fabric{} = fabric, {x, y}), do: at(fabric, x, y)

    def at(%Fabric{} = fabric, x, y) do
      Map.get(fabric.allocations, {x, y}, [])
    end

    def new(claims) do
      claims
      |> Enum.reduce(%Fabric{}, &reducer/2)
    end

    defp reducer(claim, acc) do
      Fabric.add_claim(acc, claim)
    end

    def overlapping_count(%Fabric{allocations: allocations}) do
      allocations
      |> Enum.count(fn {_pos, ids} -> Enum.count(ids) > 1 end)
    end

    def isolated_claim(%Fabric{allocations: allocations}) do
      all_ids =
        Enum.reduce(allocations, MapSet.new(), fn {_pos, ids}, acc ->
          MapSet.union(acc, MapSet.new(ids))
        end)

      overlapping_ids =
        Enum.reduce(allocations, MapSet.new(), fn {_pos, ids}, acc ->
          if Enum.count(ids) > 1 do
            MapSet.union(acc, MapSet.new(ids))
          else
            acc
          end
        end)

      MapSet.difference(all_ids, overlapping_ids)
      |> Enum.at(0)
    end
  end

  def parse_input(lines) do
    lines
    |> Enum.map(&parse_claim/1)
  end

  def parse_claim(input) do
    regex = ~r/#(?<id>\d+) @ (?<left>\d+),(?<top>\d+): (?<width>\d+)x(?<height>\d+)/

    captures =
      Regex.named_captures(regex, input)
      |> Enum.into(%{}, fn {k, v} -> {String.to_existing_atom(k), String.to_integer(v)} end)

    Map.merge(%Claim{}, captures)
  end
end

ExUnit.start(trace: true, seed: 0)

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
      File.read!("day03.txt")
      |> String.split("\n", trim: true)
    end
  end
end
