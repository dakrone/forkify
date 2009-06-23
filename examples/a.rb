#!/usr/bin/env ruby

require 'forkify'

r = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12].forkify(6) { |num|
  puts num
  sleep(1)
  num * 2
}

puts "Results: #{r.inspect}"

# This should take a little longer than 2 seconds, instead of longer than 12
# It could be done faster by changing processes => 12 to run in ~1 second.
