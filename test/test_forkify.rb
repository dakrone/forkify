require "testy"
require "forkify"

Testy.testing 'forkify' do
  test 'timings' do |t|
    time1 = Time.now
    r = [1, 2, 3].forkify(3) { |n| sleep(1) }
    time2 = Time.now
    # Assert that it took less than 3 seconds
    less_than_3 = ((time2 - time1) < 3)
    t.check :timing, :expect => true, :actual => less_than_3
  end

  test 'array results' do |t|
    r = [1, 2, 3].forkify { |n| n * 2 }
    t.check :array_results, :expect => [2, 4, 6], :actual => r
  end
end
