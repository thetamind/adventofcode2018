defmodule Day6.Grid do
  def plot(coordinates) do
    labels = labels_for(coordinates)

    for y <- 0..9 do
      for x <- 0..9 do
        point = {x, y}
        if Enum.member?(coordinates, point), do: label_for(labels, point), else: "."
      end
    end
    |> Enum.map(&Enum.join(&1))
    |> Enum.join("\n")
  end

  def label_for(labels, point), do: Map.fetch!(labels, point)

  def labels_for(coordinates) do
    letters = Stream.unfold(?A, fn letter ->
      {letter, letter + 1}
    end)
    coordinates
    |> Enum.zip(letters)
    |> Map.new(fn {point, label} -> {point, <<label>>} end)
  end
end

ExUnit.start(seed: 0, trace: true)

defmodule Day6Test do
  use ExUnit.Case, async: true

  describe "grid" do
    test "example" do
      expected =
        """
        ..........
        .A........
        ..........
        ........C.
        ...D......
        .....E....
        .B........
        ..........
        ..........
        ........F.
        """
        |> String.trim_trailing("\n")

      coordinates = [
        {1, 1},
        {1, 6},
        {8, 3},
        {3, 4},
        {5, 5},
        {8, 9}
      ]

      assert expected == Day6.Grid.plot(coordinates)
    end
  end
end
