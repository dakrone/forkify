require "test/unit"
require "forkify"

class TestForkify < Test::Unit::TestCase
  def test_timings
    time1 = Time.now
    r = [1, 2, 3].forkify(3) { |n| sleep(1) }
    time2 = Time.now
    # Assert that it took less than 3 seconds
    assert (time2 - time1) < 3
  end

  def test_array_results_returned_correctly
    r = [1, 2, 3].forkify { |n| n * 2 }
    assert r == [2, 4, 6]
  end

end
