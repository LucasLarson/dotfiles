# This is used by bin/ruby18 to fix the hardcoded loadpath
$:.each { |path| path.sub!(%r{^/Users/msheets/rubyinstalled}, "#{ENV['HOME']}/Library/Application Support/TextMate/Ruby/1.8.7") }
