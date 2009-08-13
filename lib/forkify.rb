FORKIFY_DEBUG = false

require 'pp'
require 'rinda/tuplespace'
require 'timeout'

module Enumerable

  #
  # Forkify will process _block_'s actions using processes. If no number of processes is
  # given, the default of 5 will be used. If there are less than _procs_ number of items
  # in the +Enumerable+ type, less processes will be spawned.
  #
  # It should be noted that forkify will *always* return an +Array+ at this time, so be
  # careful with +Hash+ objects.
  #
  # = Examples
  #
  #    [1, 2, 3].forkify { |n| n*2 } => [2, 4, 6]
  #
  #    {:a => 1, :b => 2, :c => 3}.forkify { |k, v| [v, k] } => [[1, :a], [2, :b], [3, :c]]
  #
  #    10.times.forkify(10) { sleep(1) } => [1, 1, 1, 1, 1, 1, 1, 1, 1, 1] (runs for less than 2 seconds)
  #
  def forkify(opts = {}, &block)
    puts opts.inspect if FORKIFY_DEBUG

    if opts.class == Fixnum # it's the number of processes
      procs = opts
      method = :serial
    elsif opts.class == Hash
      procs = opts[:procs] || 5
      method = opts[:method] || :serial
    end

    puts "procs: #{procs}, method: #{method.inspect}" if FORKIFY_DEBUG

    if method == :serial
      forkify_serial(procs, &block)
    elsif method == :pool
      if RUBY_VERSION < "1.9.1"
        raise "Pool forking is only supported on Ruby 1.9.1+"
      end
      forkify_pool(procs, &block)
    else
      raise "I don't know that method of forking: #{method}"
    end
  end

  private # should I keep these private? not sure.

  def forkify_pool procs = 5, &block
    puts "Forkify Class: #{self.class}" if FORKIFY_DEBUG
    if self === Array
      items = self
    else
      begin
        items = self.to_a
      rescue NoMethodError => e
        raise NoMethodError, "Unable to coerce #{self.inspect} to an Array type."
      end
    end

    result_tuples = []
    results = []
    pids = []
    items_remaining = items.size

    num_procs = procs
    num_procs = items_remaining if items_remaining < procs

    num_procs.times do

      pid = fork
      unless pid

        DRb.start_service

        ts = Rinda::TupleSpaceProxy.new(DRbObject.new_with_uri('druby://127.0.0.1:53421'))

        conn_attempts = 10
        done_work = false

        loop do

          # break if no more items in the queue
          break if done_work and ts.read_all([:enum, nil, nil]).empty?

          puts "#{$$} Taking..." if FORKIFY_DEBUG

          begin
          item = ts.take([:enum, nil, nil])
          rescue DRb::DRbConnError
            conn_attempts -= 1
            sleep(0.2)
            retry if conn_attempts > 0
            exit(-1)
          end
          pp "Got => #{item}" if FORKIFY_DEBUG

          # our termination tuple
          result =
            begin
              block.call(item[2])
            rescue Object => e
              e
            end

          # return result
          puts "writing result: #{result.inspect}" if FORKIFY_DEBUG
          ts.write([:result, item[1], result])
          done_work ||= true

        end
        DRb.stop_service

        puts "child #{$$} dying" if FORKIFY_DEBUG
        exit!
      end

      pids << pid
    end

    pts = Rinda::TupleSpace.new

    # write termination tuples
    #num_procs.times do
      #puts "pushing terminator" if FORKIFY_DEBUG
      #pts.write([:enum, -1, nil])
    #end

    items.each_with_index { |item, index|
      puts "pushing data" if FORKIFY_DEBUG
      pts.write([:enum, index, item])
    }

    provider = nil
    conn_attempts = 100
    loop do
      begin
        provider = DRb.start_service('druby://127.0.0.1:53421', pts)
      rescue Exception => e
        conn_attempts -= 1
        #print "."
        retry if conn_attempts > 0
        raise "bleh, I couldn't start DRb"
      else
        break
      end
    end

    pp "Waiting for pids: #{pids.inspect}" if FORKIFY_DEBUG
    pids.reverse.each { |p|
      puts "Waiting for #{p}" if FORKIFY_DEBUG
      Process.waitpid(p)
    }

    # Grab results
    items.size.times do
      puts "grabbing a result..." if FORKIFY_DEBUG
      result_tuples << pts.take([:result, nil, nil])
    end

    provider.stop_service
    # wait for death
    while provider.alive? do
      #print ":"
    end

    # gather results and sort them
    result_tuples.map { |t|
      puts "results[#{t[1]}] = #{t[2]}" if FORKIFY_DEBUG
      results[t[1]] = t[2]
    }

    return results
  end

  def forkify_serial procs = 5, &block
    puts "Forkify Class: #{self.class}" if FORKIFY_DEBUG
    if self === Array
      items = self
    else
      begin
        items = self.to_a
      rescue NoMethodError => e
        raise NoMethodError, "Unable to coerce #{self.inspect} to an Array type."
      end
    end

    results = []
    offset = 0

    items_remaining = items.size

    while (items_remaining > 0) do
      num_procs = procs
      num_procs = items_remaining if items_remaining < procs

      pids = []
      wpipes = []
      rpipes = []

      num_procs.times do |i|
        puts "Fork # #{i}" if FORKIFY_DEBUG
        r, w = IO.pipe
        pp "r, w: #{r} #{w}" if FORKIFY_DEBUG
        wpipes << w
        rpipes << r
        pid = fork
        unless pid
          r.close
          result = 
            begin
              block.call(items[i + offset])
            rescue Object => e
              e
            end
          w.write( Marshal.dump( result ))
          w.close
          exit!
        end

        pids << pid

      end

      offset += num_procs

      pp "Waiting for pids: #{pids.inspect}" if FORKIFY_DEBUG
      pids.each { |p| Process.waitpid(p) }

      # 1 select version
      #datawaiting_pipes = Kernel.select(rpipes, wpipes, nil, 2)
      #readwaiting_pipes = datawaiting_pipes[0]
      #writewaiting_pipes = datawaiting_pipes[1]

      # Switch to 2 selects instead of 1
      #readwaiting_pipes = Kernel.select(rpipes, nil, nil, 2)[0]
      #writewaiting_pipes = Kernel.select(nil, wpipes, nil, 2)[1]

      # Finally settled on going through the pipes instead of select for Linux bug
      unless rpipes.size != wpipes.size
        rpipes.size.times do |i|
          r = rpipes[i]
          w = wpipes[i]

          pp "read: #{r}" if FORKIFY_DEBUG
          pp "write: #{w}" if FORKIFY_DEBUG

          w.close
          data = ''
          while ( buf = r.read(8192) )
            data << buf
          end
          result = Marshal.load( data )
          r.close
          pp "Pushing result: #{result}" if FORKIFY_DEBUG
          results << result
        end
      end

      items_remaining -= num_procs
    end

    return results
  end

end


