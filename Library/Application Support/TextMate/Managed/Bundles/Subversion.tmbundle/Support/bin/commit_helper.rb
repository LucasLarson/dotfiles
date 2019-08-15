#!/usr/bin/env ruby18

require File.dirname(__FILE__) + '/../lib/subversion'

Subversion.run(ARGV) do |status, err|
  if status.exitstatus > 0 
    STDERR << err; exit 1; 
  end
end
puts Subversion.status(ARGV.last).commit_window_code_string