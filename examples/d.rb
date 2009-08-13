#!/usr/bin/env ruby
# vim: set ts=2 sw=2 filetype=Ruby
# 
# This example shows how pool forking can be faster than serial forking in
# some cases.

require 'forkify'

#FORKIFY_DEBUG = true

puts "Forkifying with a pool..."
pool_start_time = Time.now
pool_result = [1, 2, 3, 4, 5].forkify(:procs => 3, :method => :pool) { |n| puts "#{$$} sleeping for #{n}"; sleep(n); n }
#puts "..."
pool_result = [1, 2, 3, 4, 5].forkify(:procs => 3, :method => :pool) { |n| puts "#{$$} sleeping for #{n}"; sleep(n); n }
#pool_result = [1, 1, 1, 1, 5, 1, 3, 2].forkify(:procs => 5, :method => :pool) { |n| puts "#{$$} sleeping for #{n}"; sleep(n); n }
pool_stop_time = Time.now

#puts "Forkifying serially..."
serial_start_time = Time.now
#serial_result = [1, 1, 1, 1, 5, 1, 3, 2].forkify(:procs => 5, :method => :serial) { |n| puts "#{$$} sleeping for #{n}"; sleep(n); n }
serial_stop_time = Time.now

pool_time = pool_stop_time - pool_start_time
serial_time = serial_stop_time - serial_start_time

puts "Time with pool forking #{pool_time} seconds."
puts "Time with serial forking #{serial_time} seconds."

#puts "#{pool_result.inspect} - #{serial_result.inspect}"

