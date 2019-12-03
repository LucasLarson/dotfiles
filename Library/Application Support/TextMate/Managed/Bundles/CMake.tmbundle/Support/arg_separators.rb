#!/usr/bin/env ruby18 -wKU

commands = `/usr/local/bin/cmake --help-command-list`.to_a
commands.shift # Skip version number

constants = []

commands.each do |cmd|
  cmd = cmd.strip.upcase
  help = `/usr/local/bin/cmake --help-command #{cmd}`
  help.scan(/[a-zA-Z_]+\((.+?)\)/m) do |example|
    example[0].scan(/[A-Z_\d]{2,}/) do |constant|
      constants << constant
    end
  end
end

constants.uniq.sort.each { |constant| puts constant }