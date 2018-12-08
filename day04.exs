defmodule Day4 do
  defmodule Log do
    def parse(data) do
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

  describe "example log" do
    test "events" do
      events = Day4.Log.parse(sample_input())

      assert 17 == Enum.count(events)
      expected = {~N[1518-11-01 00:00:00], "Guard #10 begins shift"}
      assert expected == Enum.at(events, 0)
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
