defmodule Day11Test do
  use ExUnit.Case, async: true

  import Day11

  describe "answer/1" do
    test "example 1" do
      assert {{33, 45}, 29} == answer(serial: 18)
    end

    test "example 2" do
      assert {{21, 61}, 30} == answer(serial: 42)
    end

    test "puzzle" do
      assert {{243, 43}, 29} == answer(serial: 4172)
    end
  end

  describe "answer2/1" do
    test "example 1" do
      assert {{90, 269}, 16, 113} == answer_part2(serial: 18)
    end

    test "example 2" do
      assert {{232, 251}, 12, 119} == answer_part2(serial: 42)
    end

    test "puzzle" do
      assert {{236, 151}, 15, 127} == answer_part2(serial: 4172)
    end
  end

  describe "square_power/2" do
    test "example 1" do
      assert 29 == square_power(grid(serial: 18), {33, 45}, 3)
    end

    test "example 2" do
      assert 30 == square_power(grid(serial: 42), {21, 61}, 3)
    end
  end

  describe "cell_power/2" do
    test "example 1" do
      assert 4 == cell_power(8, {3, 5})
    end

    test "example 2" do
      assert -5 == cell_power(57, {122, 79})
    end

    test "example 3" do
      assert 0 == cell_power(39, {217, 196})
    end

    test "example 4" do
      assert 4 == cell_power(71, {101, 153})
    end
  end

  describe "third_digit/1" do
    test "present" do
      assert 9 == third_digit(949)
      assert 3 == third_digit(12345)
      assert 5 == third_digit(1_234_567)
    end

    test "absent" do
      assert 0 == third_digit(42)
    end
  end
end
