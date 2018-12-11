defmodule Day4 do
  defmodule Log do
    def parse(data) do
      data
      |> parse_lines()
      |> process_log
    end

    # date, message
    # date, event, guard_id
    # {month, day}, guard_id, {sleep, awake}
    def process_log(lines) do
      lines
      |> Enum.sort(fn {date1, _}, {date2, _} -> NaiveDateTime.compare(date1, date2) == :lt end)
      |> Enum.reduce({nil, []}, fn {date, message}, {guard, acc} ->
        guard =
          case Regex.run(~r/#(\d+)/, message) do
            [_, id] -> String.to_integer(id)
            nil -> guard
          end

        event =
          case message do
            "falls asleep" -> {date.month, date.day, guard, :sleep, date.minute}
            "wakes up" -> {date.month, date.day, guard, :awake, date.minute}
            _ -> nil
          end

        acc = if event, do: [event | acc], else: acc

        {guard, acc}
      end)
      |> elem(1)
      |> Enum.reverse()
    end

    def parse_lines(data) do
      data
      |> String.split("\n", trim: true)
      |> Enum.map(&parse_line/1)
    end

    def parse_line(line) do
      pattern = ~r/\[(.*)\]\s(.*)/

      [_all, timestamp, message] = Regex.run(pattern, line)

      date = NaiveDateTime.from_iso8601!(timestamp <> ":00")
      {date, message}
    end

    def _parse_line_detailed(line) do
      pattern = ~r/
        \[(?<year>\d{4})-(?<month>\d{2})-(?<day>\d{2})\s
        (?<hour>\d{2}):(?<minute>\d{2})\]\s
        (?<message>.*)
        /x

      Regex.named_captures(pattern, line)
    end
  end

  defmodule Interval do
    @enforce_keys [:start, :stop]
    defstruct [:start, :stop]

    @type t :: %Interval{
            start: non_neg_integer,
            stop: non_neg_integer
          }

    def member?(%Interval{stop: stop}, element) when element == stop, do: false

    def member?(%Interval{start: start, stop: stop}, element) do
      start..stop
      |> Enum.member?(element)
    end

    def minutes(%Interval{start: start, stop: stop}) do
      stop - start
    end

    def to_list(%Interval{start: start, stop: stop}) when start == stop, do: []

    def to_list(%Interval{start: start, stop: stop}) do
      start..(stop - 1)
      |> Enum.to_list()
    end
  end

  defmodule Chart do
    def chart(events) do
      title = "Date   ID     Minute"
      spacer = String.pad_leading("", 14)

      header1 =
        0..5
        |> Enum.map(&String.duplicate(to_string(&1), 10))
        |> Enum.join()

      header2 = String.duplicate(to_string("0123456789"), 6)

      days = to_days(events)

      report_minute = fn minute, intervals ->
        if Enum.any?(intervals, &Interval.member?(&1, minute)), do: "#", else: "."
      end

      report_day = fn {{month, day, guard}, intervals} ->
        pad = fn el, count ->
          String.pad_leading(to_string(el), count)
        end

        pad0 = fn el, count ->
          String.pad_leading(to_string(el), count, ["0"])
        end

        dots = Enum.map(0..59, &report_minute.(&1, intervals))

        "#{pad.(month, 2)}-#{pad0.(day, 2)}  ##{pad.(guard, 4)}  #{dots}"
      end

      body = days |> Enum.map(report_day) |> Enum.join("\n")

      header = title <> "\n" <> spacer <> header1 <> "\n" <> spacer <> header2 <> "\n"

      header <> body
    end

    def to_days(events) do
      events
      |> Enum.group_by(
        fn {month, day, guard, _, _} ->
          {month, day, guard}
        end,
        fn {_, _, _, action, minute} ->
          {action, minute}
        end
      )
      |> Enum.into(%{}, fn {k, actions} ->
        {k, to_intervals(actions)}
      end)
      |> Enum.sort_by(fn {{month, day, _}, _} -> {month, day} end)
    end

    def to_interval([{:sleep, start}, {:awake, stop}]) do
      %Interval{start: start, stop: stop}
    end

    def to_intervals(actions) do
      actions
      |> Enum.chunk_every(2)
      |> Enum.map(&to_interval/1)
    end
  end

  defmodule Strategy1 do
    def solve(events) do
      {guard, _} = sleepiest_guard(events)
      minute = sleepiest_guard_minute(events, guard)

      guard * minute
    end

    def sleepiest_guard(events) do
      days = Day4.Chart.to_days(events)

      days
      |> Enum.map(&sleep_time/1)
      |> Enum.reduce(%{}, fn {guard, minutes}, acc ->
        Map.update(acc, guard, minutes, &(&1 + minutes))
      end)
      |> Enum.sort_by(&elem(&1, 1), &>=/2)
      |> Enum.at(0)
    end

    def sleepiest_guard_minute(events, guard) do
      days = Day4.Chart.to_days(events)

      intervals =
        days
        |> Enum.filter(fn {{_, _, id}, _} ->
          guard == id
        end)
        |> Enum.flat_map(&elem(&1, 1))

      0..59
      |> Enum.reduce(%{}, fn minute, acc ->
        sleeping_count =
          Enum.filter(intervals, &Interval.member?(&1, minute))
          |> Enum.count()

        Map.update(acc, minute, sleeping_count, &(&1 + sleeping_count))
      end)
      |> Enum.sort_by(&elem(&1, 1), &>=/2)
      |> Enum.at(0)
      |> elem(0)
    end

    def sleep_time({{_, _, guard}, intervals}) do
      minutes = Enum.map(intervals, &Interval.minutes/1) |> Enum.sum()
      {guard, minutes}
    end
  end

  defmodule Strategy2 do
    # group by guard
    # count by minute sleeping
    def solve(events) do
      {guard, {minute, _count}} = sleepiest_guard_minute(events)

      guard * minute
    end

    def sleepiest_guard_minute(events) do
      days = Day4.Chart.to_days(events)

      days
      |> Enum.map(&sleeping_minutes/1)
      |> Enum.group_by(&elem(&1, 0), &elem(&1, 1))
      |> Enum.map(fn {k, intervals} ->
        minutes =
          intervals
          |> List.flatten()
          |> Enum.flat_map(&Interval.to_list/1)
          |> Enum.reduce(%{}, fn minute, acc ->
            Map.update(acc, minute, 1, &(&1 + 1))
          end)
          |> Enum.sort_by(fn {_minute, count} -> count end, &>=/2)
          |> Enum.at(0)

        {k, minutes}
      end)
      |> Enum.sort_by(fn {_guard, {_minute, count}} -> count end, &>=/2)
      |> Enum.at(0)

      # &{guard => [intervals]}
      # &{guard => [minutes]}
      # &{guard => most slept minute}
      # |> Enum.sort_by()
    end

    def sleeping_minutes({{_, _, guard}, intervals}) do
      {guard, intervals}
    end

    def sleepiest_guard(events) do
      days = Day4.Chart.to_days(events)

      days
      |> Enum.map(&sleep_time/1)
      |> Enum.reduce(%{}, fn {guard, minutes}, acc ->
        Map.update(acc, guard, minutes, &(&1 + minutes))
      end)
      |> Enum.sort_by(&elem(&1, 1), &>=/2)
      |> Enum.at(0)
    end

    def sleep_time({{_, _, guard}, intervals}) do
      minutes = Enum.map(intervals, &Interval.minutes/1) |> Enum.sum()
      {guard, minutes}
    end
  end
end

ExUnit.start(seed: 0, trace: true)

defmodule Day4Test do
  use ExUnit.Case, async: true

  alias Day4.Interval

  describe "Interval" do
    test "member?" do
      interval = %Interval{start: 10, stop: 25}
      assert Interval.member?(interval, 10)
      assert Interval.member?(interval, 20)
      refute Interval.member?(interval, 25)
    end

    test "member? empty interval" do
      interval = %Interval{start: 0, stop: 0}
      refute Interval.member?(interval, 0)
      refute Interval.member?(interval, 1)
    end

    test "member? reverse interval" do
      interval = %Interval{start: 0, stop: -1}
      assert Interval.member?(interval, 0)
      refute Interval.member?(interval, -1)
      refute Interval.member?(interval, 1)
    end

    test "to_list" do
      interval = %Interval{start: 2, stop: 8}
      assert [2, 3, 4, 5, 6, 7] == Interval.to_list(interval)

      interval = %Interval{start: 0, stop: 0}
      assert [] == Interval.to_list(interval)
    end
  end

  describe "example" do
    test "parse log" do
      lines = Day4.Log.parse_lines(sample_input())

      assert 17 == Enum.count(lines)
      expected = {~N[1518-11-01 00:00:00], "Guard #10 begins shift"}
      assert expected == Enum.at(lines, 0)
    end

    test "log to events" do
      events = Day4.Log.parse(sample_input())

      assert 12 == Enum.count(events)
      assert {11, 1, 10, :sleep, 5} = Enum.at(events, 0)
      assert {11, 1, 10, :awake, 25} = Enum.at(events, 1)
      assert {11, 1, 10, :sleep, 30} = Enum.at(events, 2)
      assert {11, 1, 10, :awake, 55} = Enum.at(events, 3)
      assert {11, 2, 99, :sleep, 40} = Enum.at(events, 4)
    end

    test "visual chart" do
      events = Day4.Log.parse(sample_input())

      expected =
        """
        Date   ID     Minute
                      000000000011111111112222222222333333333344444444445555555555
                      012345678901234567890123456789012345678901234567890123456789
        11-01  #  10  .....####################.....#########################.....
        11-02  #  99  ........................................##########..........
        11-03  #  10  ........................#####...............................
        11-04  #  99  ....................................##########..............
        11-05  #  99  .............................................##########.....
        """
        |> String.trim_trailing("\n")

      assert expected == Day4.Chart.chart(events)
    end

    test "strategy 1 solution" do
      events = Day4.Log.parse(sample_input())
      assert 240 == Day4.Strategy1.solve(events)
    end

    test "strategy 1 sleepiest guard" do
      events = Day4.Log.parse(sample_input())
      assert {10, 50} == Day4.Strategy1.sleepiest_guard(events)
    end

    test "strategy 1 sleepiest guard minute" do
      events = Day4.Log.parse(sample_input())
      {guard, _} = Day4.Strategy1.sleepiest_guard(events)
      assert 24 == Day4.Strategy1.sleepiest_guard_minute(events, guard)
    end

    test "strategy 2 solution" do
      events = Day4.Log.parse(sample_input())
      assert 4455 == Day4.Strategy2.solve(events)
    end

    test "strategy 2 sleepiest guard minute" do
      events = Day4.Log.parse(sample_input())
      assert {99, {45, 3}} = Day4.Strategy2.sleepiest_guard_minute(events)
    end

    defp sample_input do
      """
      [1518-11-01 00:00] Guard #10 begins shift
      [1518-11-01 00:05] falls asleep
      [1518-11-01 00:25] wakes up
      [1518-11-01 00:30] falls asleep
      [1518-11-01 00:55] wakes up
      [1518-11-01 23:58] Guard #99 begins shift
      [1518-11-02 00:40] falls asleep
      [1518-11-02 00:50] wakes up
      [1518-11-03 00:05] Guard #10 begins shift
      [1518-11-03 00:24] falls asleep
      [1518-11-03 00:29] wakes up
      [1518-11-04 00:02] Guard #99 begins shift
      [1518-11-04 00:36] falls asleep
      [1518-11-04 00:46] wakes up
      [1518-11-05 00:03] Guard #99 begins shift
      [1518-11-05 00:45] falls asleep
      [1518-11-05 00:55] wakes up
      """
    end
  end

  describe "puzzle" do
    test "visual chart" do
      events = Day4.Log.parse(puzzle_input())
      chart = Day4.Chart.chart(events)

      expected =
        """
        Date   ID     Minute
                      000000000011111111112222222222333333333344444444445555555555
                      012345678901234567890123456789012345678901234567890123456789
         3-06  #2963  .........................#####################..............
         3-07  #  89  ...............##################...........................
         3-08  #3137  .................#######........########################....
         3-09  #3511  .........###########..............................######....
         3-10  #2251  ................####################...#################....
         3-11  # 857  .....................#######################................
         3-12  #  89  ..###############.....##########################......#####.
        """
        |> String.trim_trailing("\n")

      length = String.length(expected)
      part = String.split_at(chart, length) |> elem(0)

      assert expected == part
    end

    test "strategy 1 solution" do
      events = Day4.Log.parse(puzzle_input())
      assert 39_422 == Day4.Strategy1.solve(events)
    end

    test "strategy 1 sleepiest guard minute" do
      events = Day4.Log.parse(puzzle_input())
      {guard, _} = Day4.Strategy1.sleepiest_guard(events)
      assert 46 == Day4.Strategy1.sleepiest_guard_minute(events, guard)
    end

    test "strategy 2 solution" do
      events = Day4.Log.parse(puzzle_input())
      assert 65_474 == Day4.Strategy2.solve(events)
    end

    test "strategy 2 sleepiest guard minute" do
      events = Day4.Log.parse(puzzle_input())
      assert {1723, {38, 20}} = Day4.Strategy2.sleepiest_guard_minute(events)
    end

    def puzzle_input do
      File.read!("day04.txt")
    end
  end
end
