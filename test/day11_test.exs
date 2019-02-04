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

  describe "square_power/2" do
    test "example 1" do
      assert 29 == square_power(grid(serial: 18), {33, 45})
    end

    test "example 2" do
      assert 30 == square_power(grid(serial: 42), {21, 61})
    end
  end

  describe "cell_power/2" do
    test "example 1" do
      assert 4 == grid(serial: 8) |> cell_power({3, 5})
    end

    test "example 2" do
      assert -5 == grid(serial: 57) |> cell_power({122, 79})
    end

    test "example 3" do
      assert 0 == grid(serial: 39) |> cell_power({217, 196})
    end

    test "example 4" do
      assert 4 == grid(serial: 71) |> cell_power({101, 153})
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
