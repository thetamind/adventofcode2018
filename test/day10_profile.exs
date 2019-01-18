defmodule Day10S do
  def parse(input), do: Stream.map(input, &parse_line/1)

  def parse_line(line) do
    line
    |> String.split(["<", ">", ","])
    |> Enum.map(&String.trim/1)
    |> parts_to_points()
  end

  def parts_to_points([_, px, py, _, vx, vy | _]) do
    %{px: px, py: py, vx: vx, vy: vy}
    |> Enum.into(%{}, fn {k, v} -> {k, String.to_integer(v)} end)
  end

  def to_sky(points) do
    points
  end

  def light_at(sky, {x, y}) do
    Enum.any?(sky, fn %{px: px, py: py} ->
      px == x and py == y
    end)
  end

  def light_stream(sky) do
    Stream.iterate(sky, &move_lights/1)
  end

  def move_lights(sky) do
    Stream.map(sky, &move_light/1)
  end

  def move_light(%{px: px, py: py, vx: vx, vy: vy}) do
    %{px: px + vx, py: py + vy, vx: vx, vy: vy}
  end

  def print_sky(sky, extents) do
    points = MapSet.new(sky, fn %{px: px, py: py} -> {px, py} end)

    plot(points, extents)
    |> puts()
  end

  def puts(plot) do
    plot
    |> Enum.map(&Enum.join(&1))
    |> Enum.join("\n")
    |> IO.puts()
  end

  # extents: {-49919, 50232, -49910, 50189}
  # {50_170, 50_200, -29_880, -29_910}

  require Logger

  def plot(lights, {left, right, top, bottom}) do
    Logger.debug(inspect(lights))

    for y <- top..bottom do
      for x <- left..right do
        point = {x, y}
        if Enum.member?(lights, point), do: "#", else: "."
      end
    end
  end

  def extents(sky) do
    sky
    |> MapSet.new(fn %{px: px, py: py} -> {px, py} end)
    |> Enum.reduce({0, 0, 0, 0}, fn {x, y}, {xmin, xmax, ymin, ymax} ->
      {min(x, xmin), max(x, xmax), min(y, ymin), max(y, ymax)}
    end)
  end

  def magnitude({left, right, top, bottom}) do
    {right - left, top - bottom}
  end

  def find_message_zero_origin(light_stream) do
    light_stream
    |> Stream.with_index()
    |> Stream.each(fn {_, second} -> IO.puts("#{second}") end)
    |> Stream.filter(fn {sky, _second} ->
      Enum.all?(sky, fn %{px: px, py: py} ->
        px >= 0 and py >= 0
      end)
    end)
    |> Enum.take(1)
    |> Enum.at(0)
  end

  def find_message_vertical(light_stream) do
    light_stream
    |> Stream.with_index()
    # |> Stream.each(fn {_, second} -> IO.puts("#{second}") end)
    |> Stream.map(fn {sky, second} ->
      score = score_vertical(sky)
      if rem(second, 10) == 0, do: Logger.debug("[#{second}] score: #{score}")
      {sky, second, score}
    end)
    |> Enum.reduce_while({nil, -1, 0}, fn {_sky, second, score} = current, prev ->
      {_, _, prev_score} = prev

      if second >= 150 do
        {:halt, prev}
      else
        if score >= prev_score do
          {:cont, current}
        else
          {:halt, prev}
        end
      end
    end)
  end

  def score_vertical(sky) do
    groups =
      sky
      |> Enum.group_by(fn %{px: px} -> px end, fn _ -> [] end)
      |> Enum.map(fn {x, lights} -> {x, Enum.count(lights)} end)
      |> Enum.filter(fn {_x, count} -> count >= 5 end)

    # pad = fn s -> String.pad_leading(to_string(s), 5) end

    # Logger.debug(fn ->
    #   Enum.map(groups, fn {x, count} -> "#{pad.(x)}=>#{count}" end)
    #   |> Enum.join("  ")
    # end)

    groups
    |> Enum.map(fn {_, count} -> count end)
    |> Enum.sum()
  end
end

defmodule Prof do
  alias Day10S

  # ExUnit.start(seed: 0)

  # defmodule Day10T do
  #   use ExUnit.Case

  #   describe "find_message_zero_origin/1" do
  #     test "example - zero origin strategy" do

  #       {sky, second} =
  #         example_input()
  #         |> Day10S.light_stream()
  #         |> Day10S.find_message_zero_origin()

  #       Process.sleep(500)
  #       assert 3 == second
  #       assert Day10S.light_at(sky, {8, 5})
  #       refute Day10S.light_at(sky, {5, 5})
  #     end
  #   end

  def example_input do
    """
    position=< 9,  1> velocity=< 0,  2>
    position=< 7,  0> velocity=<-1,  0>
    position=< 3, -2> velocity=<-1,  1>
    position=< 6, 10> velocity=<-2, -1>
    position=< 2, -4> velocity=< 2,  2>
    position=<-6, 10> velocity=< 2, -2>
    position=< 1,  8> velocity=< 1, -1>
    position=< 1,  7> velocity=< 1,  0>
    position=<-3, 11> velocity=< 1, -2>
    position=< 7,  6> velocity=<-1, -1>
    position=<-2,  3> velocity=< 1,  0>
    position=<-4,  3> velocity=< 2,  0>
    position=<10, -3> velocity=<-1,  1>
    position=< 5, 11> velocity=< 1, -2>
    position=< 4,  7> velocity=< 0, -1>
    position=< 8, -2> velocity=< 0,  1>
    position=<15,  0> velocity=<-2,  0>
    position=< 1,  6> velocity=< 1,  0>
    position=< 8,  9> velocity=< 0, -1>
    position=< 3,  3> velocity=<-1,  1>
    position=< 0,  5> velocity=< 0, -1>
    position=<-2,  2> velocity=< 2,  0>
    position=< 5, -2> velocity=< 1,  2>
    position=< 1,  4> velocity=< 2,  1>
    position=<-2,  7> velocity=< 2, -2>
    position=< 3,  6> velocity=<-1, -1>
    position=< 5,  0> velocity=< 1,  0>
    position=<-6,  0> velocity=< 2,  0>
    position=< 5,  9> velocity=< 1, -2>
    position=<14,  7> velocity=<-2,  0>
    position=<-3,  6> velocity=< 2, -1>
    """
    |> String.trim_trailing("\n")
    |> String.split("\n")
    |> Day10S.parse()
  end

  def puzzle_input() do
    File.stream!("priv/day10.txt")
    |> Day10S.parse()
    |> Enum.to_list()
  end
end

example = Prof.example_input()
puzzle = Prof.puzzle_input()

Mix.Tasks.Profile.Fprof.profile(
  fn ->
    {sky, second, score} =
      puzzle
      |> Day10S.light_stream()
      |> Day10S.find_message_vertical()

    IO.puts("#{second}: #{score}")
  end,
  sort: :own,
  callers: true
)
