#!/usr/bin/env ruby
# vim: set ts=2 sw=2 filetype=Ruby
# 
# This example shows a problem with the current implementation of forkify:
# if a fork finishes work, it will still wait for the other forks to finish
# in the process pool before forking new processes for work.
#
# I hope to remedy this as soon as I figure out a good solution for it.

require 'forkify'

[1, 1, 1, 1, 5, 1].forkify(5) { |n| puts n; sleep(n); n }

# 0.04s user 0.06s system 1% cpu 6.031 total
# (would be possible to run in a little over 5)
