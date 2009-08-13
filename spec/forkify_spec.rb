$: << File.dirname(__FILE__) + "/../lib"

require 'spec'
require 'forkify'

describe 'forkify' do
  it 'should fork serially and take less time' do
    time1 = Time.now
    r = [1, 2, 3].forkify(3) { |n| sleep(1) }
    time2 = Time.now
    # Assert that it took less than 3 seconds
    (time2 - time1).should < 3
  end

  it 'should fork with a pool and take less time' do
    time1 = Time.now
    r = [1, 2, 3].forkify(:procs => 3, :method => :pool) { |n| sleep(1) }
    time2 = Time.now
    # Assert that it took less than 3 seconds
    (time2 - time1).should < 3
  end

  it 'should return an array of results from a serial fork' do
    [1, 2, 3].forkify { |n| n * 2 }.should == [2, 4, 6]
  end

  it 'should return an array of results from a pool fork' do
    [1, 2, 3].forkify(:method => :pool) { |n| n * 2 }.should == [2, 4, 6]
  end

  it 'should return a hash of results from a serial fork' do
    r = {:a => 1, :b => 2, :c => 3}.forkify { |k, v| [k, v*2] }
    r.should include([:a, 2])
    r.should include([:b, 4])
    r.should include([:c, 6])
    r.size.should == 3
  end

  it 'should return a hash of results from a pool fork' do
    r = {:a => 1, :b => 2, :c => 3}.forkify(:method => :pool) { |k, v| [k, v*2] }
    r.should include([:a, 2])
    r.should include([:b, 4])
    r.should include([:c, 6])
    r.size.should == 3
  end

  it 'should return an array of nils from a serial nil fork' do
    [nil, nil].forkify { |n| n }.should == [nil, nil]
  end

  it 'should return an array of nils from a pool nil fork' do
    [nil, nil].forkify(:method => :pool) { |n| n }.should == [nil, nil]
  end
end
