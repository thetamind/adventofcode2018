defmodule Day9 do
  alias __MODULE__.Circle

  defstruct circle: nil, current_player: 0, num_players: 0

  @type t :: %__MODULE__{
          circle: Circle.t(),
          current_player: non_neg_integer,
          num_players: pos_integer
        }

  @spec new(non_neg_integer) :: Day9.t()
  def new(num_players) do
    %__MODULE__{
      circle: Circle.new([0]),
      num_players: num_players
    }
  end

  def highest_score(game) do
    game.current_player
  end

  @spec play(non_neg_integer(), integer()) :: any()
  def play(num_players, last_marble) do
    IO.puts("\n\nPlaying #{num_players} players to marble #{last_marble}")
    Process.sleep(20)
    IO.puts("\n[  -]  (0)")
    x = Enum.reduce(1..last_marble, new(num_players), &take_turn(&2, &1))
    Process.sleep(10)
    x
  end

  @spec take_turn(Day9.t(), Day9.element()) :: Day9.t()
  def take_turn(game, marble) do
    circle = game.circle |> Circle.next() |> Circle.next() |> Circle.insert(marble)
    game = next_player(%Day9{game | circle: circle})
    if Enum.count(Circle.to_list(game.circle)) < 60, do: IO.puts(inspect_turn(game))
    Process.sleep(10)
    game
  end

  @spec next_player(t) :: t
  def next_player(game) do
    %Day9{game | current_player: rem(game.current_player + 1, game.num_players)}
  end

  def inspect_turn(%__MODULE__{current_player: player} = game) do
    {current, marbles} = inspect_circle(game)
    bright = fn string -> IO.ANSI.format([:bright, string]) |> to_string() end
    pad = fn string -> String.pad_leading(string, 4) end

    marbles =
      Enum.reduce(marbles, "", fn number, acc ->
        acc <>
          case number do
            ^current -> "(#{number})" |> pad.() |> bright.()
            _ -> "#{number} " |> pad.()
          end
      end)

    p = String.pad_leading("#{player}", 3)

    "[#{p}] #{marbles}"
  end

  def inspect_circle(game) do
    current = Circle.peek(game.circle)
    circle = Circle.to_list(game.circle)
    {current, circle}
  end
end

defmodule Day9.Circle do
  @moduledoc """
  Based on: https://github.com/sasa1977/aoc/blob/master/lib/2018/day9.ex
  """
  @type element :: non_neg_integer
  @opaque t :: {[element()], [element()]}

  @spec new([element]) :: t
  def new(elements), do: {elements, []}

  @spec next(t) :: t
  def next({[], prev}), do: next({Enum.reverse(prev), []})
  def next({[current | rest], prev}), do: {rest, [current | prev]}

  @spec prev(t) :: t
  def prev({next, []}), do: prev({[], Enum.reverse(next)})
  def prev({next, [last | rest]}), do: {[last | next], rest}

  @spec insert(t, element) :: t
  def insert({next, prev}, element), do: {[element | next], prev}

  @spec pop(t) :: {element, t}
  def pop({[], prev}), do: pop({Enum.reverse(prev), []})
  def pop({[current | rest], prev}), do: {current, {rest, prev}}

  @spec peek(t) :: element
  def peek({[current | _], _}), do: current

  @spec to_list(t) :: [element]
  def to_list({[0 | _] = next, prev}), do: Enum.concat(next, Enum.reverse(prev))
  def to_list({next, prev}), do: to_list(prev({next, prev}))
end
