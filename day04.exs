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
      |> Enum.sort_by(fn {date, _} -> date end)
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
end

ExUnit.start(seed: 0, trace: true)

defmodule Day4Test do
  use ExUnit.Case, async: true

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

    defp sample_input() do
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
end
