defmodule Day14Test do
  use ExUnit.Case, async: true

  describe "next_ten/1" do
    test "returns scores of the next ten recipes" do
      assert 5_158_916_779 == Day14.next_ten(9)
      assert 0_124_515_891 == Day14.next_ten(5)
    end
  end
end
