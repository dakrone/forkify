FORKIFY_DEBUG = false
require 'pp' if FORKIFY_DEBUG

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
  def forkify procs = 5, &block
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


