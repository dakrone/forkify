require 'testy'
require 'forkify'

Testy.testing 'forkify' do
  test 'serial timings' do |t|
    time1 = Time.now
    r = [1, 2, 3].forkify(3) { |n| sleep(1) }
    time2 = Time.now
    # Assert that it took less than 3 seconds
    less_than_3 = ((time2 - time1) < 3)
    t.check :timing, :expect => true, :actual => less_than_3
  end

  test 'pool timings' do |t|
    time1 = Time.now
    r = [1, 2, 3].forkify(:procs => 3, :method => :pool) { |n| sleep(1) }
    time2 = Time.now
    # Assert that it took less than 3 seconds
    less_than_3 = ((time2 - time1) < 3)
    t.check :timing, :expect => true, :actual => less_than_3
  end

  test 'serial array results' do |t|
    r = [1, 2, 3].forkify { |n| n * 2 }
    t.check :array_results, :expect => [2, 4, 6], :actual => r
  end

  test 'pool array results' do |t|
    r = [1, 2, 3].forkify(:method => :pool) { |n| n * 2 }
    t.check :array_results, :expect => [2, 4, 6], :actual => r
  end

  test 'serial hash results' do |t|
    r = {:a => 1, :b => 2, :c => 3}.forkify { |k, v| [k, v*2] }
    t.check :hash_contains_a, :expect => true, :actual => r.include?([:a, 2])
    t.check :hash_contains_b, :expect => true, :actual => r.include?([:b, 4])
    t.check :hash_contains_c, :expect => true, :actual => r.include?([:c, 6])
    t.check :hash_length, :expect => 3, :actual => r.size
  end

  test 'pool hash results' do |t|
    r = {:a => 1, :b => 2, :c => 3}.forkify(:method => :pool) { |k, v| [k, v*2] }
    t.check :hash_contains_a, :expect => true, :actual => r.include?([:a, 2])
    t.check :hash_contains_b, :expect => true, :actual => r.include?([:b, 4])
    t.check :hash_contains_c, :expect => true, :actual => r.include?([:c, 6])
    t.check :hash_length, :expect => 3, :actual => r.size
  end

  test 'serial array of nils' do |t|
    r = [nil, nil].forkify { |n| n }
    t.check :nil_array, :expect => [nil, nil], :actual => r
  end

  test 'pool array of nils' do |t|
    r = [nil, nil].forkify(:method => :pool) { |n| n }
    t.check :nil_array, :expect => [nil, nil], :actual => r
  end
end
