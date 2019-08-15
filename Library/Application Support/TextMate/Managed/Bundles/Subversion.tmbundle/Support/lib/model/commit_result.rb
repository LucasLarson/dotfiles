module Subversion

  class CommitResult

    attr_accessor :out

    def initialize(out)
      @out = out
    end

    def to_s
      if commits?
        out.split("\n").last
      else
        @out
      end
    end

    def commits?
      not (@out.nil? or @out.strip.empty?)
    end
    
    def files
      if @files.nil?
        if commits?
          out_lines = @out.split("\n")
          out_lines.pop # Remove 'Committed …'
          out_lines.pop # Remove 'Transmitting …'
          @files = []
          out_lines.each do |line|
            line =~ /\w+\s+(.+)$/
            @files << $1
          end
        else
          @files = []
        end
      end
      @files
    end

  end
end

if __FILE__ == $0
  commit_result = Subversion::CommitResult.new(STDIN.read)
  puts "commits: #{commit_result.commits?}"
  puts "revision: #{commit_result.revision}"
  puts "out: #{commit_result.out}"
end