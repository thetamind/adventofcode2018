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
