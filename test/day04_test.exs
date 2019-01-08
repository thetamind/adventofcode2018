
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
