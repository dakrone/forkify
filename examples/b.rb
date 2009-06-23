#!/usr/bin/env ruby

require 'forkify'

r = { :a => 1, :b => 2, :c => 3 }.forkify { |k, v|
  puts "#{k}, #{v}"
  sleep(1)
  [k, v]
}

puts "Results: #{r.inspect}"

# This should take a little longer than 1 second, rather than longer than 3 seconds.
