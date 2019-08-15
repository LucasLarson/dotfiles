# -----------------------
# TextMate::Process.run()
# -----------------------
# Method for opening processes under TextMate.
#
# # BASIC USAGE
#
# 1. out, err = TextMate::Process.run("svn", "commit", "-m", "A commit message")
#
#   'out' and 'err' are the what the process produced on stdout and stderr respectively.
#
# 2. TextMate::Process.run("svn", "commit", "-m", "A commit message") do |str, type|
#   case type
#   when :out
#     STDOUT << str
#   when :err
#     STDERR << str
#   end
# end
#
#   The block will be called with the output of the process as it becomes available.
#
# 3. TextMate::Process.run("svn", "commit", "-m", "A commit message") do |str|
#   STDOUT << str
# end
#
#   Similar to 2, except that the type of the output is not passed.
#
# # OPTIONS
#
# The last (non block) argument to run() can be a Hash that will augment the behaviour.
# The available options are (with default values in parenthesis)…
#
# * :granularity (:line)
#
# The size of the buffer to use to read the process output. The value :line
# indicates that output will be passed a line at a time. Any other non integer
# value will result in an unspecified buffer size being used.
#
# * :input (nil)
#
# A string to send to the stdin of the process.
#
# * :env (nil)
#
# A hash of environment variables to set for the process.
#
# NOTES
#
# The following is not valid Ruby…
#
#   args = ["commit", "-m", "commit message"]
#   TextMate::Process("svn", *args, :buffer => true)
#
# To get around this, arguments to run() are flattened. This allows the
# almost as good version…
#
#   args = ["commit", "-m", "commit message"]
#   TextMate::Process("svn", args, :buffer => true)
#

require ENV['TM_SUPPORT_PATH'] + '/lib/io'
require 'fcntl'

def pid_exists?(pid)
  %x{ps >/dev/null -xp #{pid}}
  $? == 0
end

def kill_and_wait(pid)
  begin
    Process.kill("-INT", pid)
    20.times { return unless pid_exists?(pid); sleep 0.02 }
    Process.kill("-TERM", pid)
    20.times { return unless pid_exists?(pid); sleep 0.02 }
    Process.kill("-KILL", pid)
  rescue
    # process doesn't exist anymore
  end
end

def setup_kill_handler(pid, &block)
  Signal.trap("USR1") do
    cmd = %x{/bin/ps -wwp #{pid} -o "command="}.chomp
    if $? == 0
      block.call("^C: #{cmd} (pid: #{pid})\n", :err)
      kill_and_wait(pid)
    end
  end
end

module TextMate
  module Process
    class << self

      def run(*cmd, &block)

        cmd.flatten!

        options = {
          :granularity => :line,
          :input => nil,
          :env => nil,
        }

        options.merge! cmd.pop if cmd.last.is_a? Hash

        io = []
        3.times { io << ::IO::pipe }
        io.flatten.each { |fd| fd.fcntl(Fcntl::F_SETFD, Fcntl::FD_CLOEXEC) }

        pid = fork {
          at_exit { exit! }
          
          STDIN.reopen(io[0][0])
          STDOUT.reopen(io[1][1])
          STDERR.reopen(io[2][1])

          options[:env].each { |k,v| ENV[k] = v } unless options[:env].nil?
          Dir.chdir(options[:chdir]) if options.has_key?(:chdir) and File.directory?(options[:chdir])
          ::Process.setsid
          exec(*cmd.compact)
        }

        Signal.trap("INT")  { ::Process.kill("-INT", pid)  }
        Signal.trap("TERM") { ::Process.kill("-TERM", pid) }

        [ io[0][0], io[1][1], io[2][1] ].each { |fd| fd.close }

        if options[:input].nil?
          io[0][1].close
        else
          Thread.new { (io[0][1] << options[:input]).close }
        end

        out = ""
        err = ""

        block ||= proc { |str, fd|
          case fd
            when :out then out << str
            when :err then err << str
          end
        }

        previous_block_size = IO.blocksize
        IO.blocksize = options[:granularity] if options[:granularity].is_a? Integer
        previous_sync = IO.sync
        IO.sync = true unless options[:granularity] == :line

        setup_kill_handler(pid, &block)

        IO.exhaust({ :out => io[1][0], :err => io[2][0] }, &block)
        ::Process.waitpid(pid)

        IO.blocksize = previous_block_size
        IO.sync = previous_sync

        block_given? ? nil : [out,err]
      end

    end
  end
end