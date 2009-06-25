#require 'pp'

module Enumerable
  def forkify procs = 5, &block
    #puts "Class: #{self.class}"
    if Array === self
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
        #puts "Fork # #{i}"
        r, w = IO.pipe
        #pp "r, w: #{r} #{w}"
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

      #pp "Waiting for pids: #{pids}"
      pids.each { |p| Process.waitpid(p) }

      datawaiting_pipes = Kernel.select(rpipes, wpipes, nil, 2)
      readwaiting_pipes = datawaiting_pipes[0]
      writewaiting_pipes = datawaiting_pipes[1]
      #pp "data: #{datawaiting_pipes}"
      #pp "read: #{readwaiting_pipes}"
      #pp "write: #{writewaiting_pipes}"
      unless readwaiting_pipes.size != writewaiting_pipes.size
        readwaiting_pipes.size.times do |i|
          r = readwaiting_pipes[i]
          w = writewaiting_pipes[i]
          w.close
          data = ''
          while ( buf = r.read(8192) )
            data << buf
          end
          result = Marshal.load( data )
          r.close
          results << result
        end
      end

      items_remaining -= num_procs
    end

    return results
  end

end


