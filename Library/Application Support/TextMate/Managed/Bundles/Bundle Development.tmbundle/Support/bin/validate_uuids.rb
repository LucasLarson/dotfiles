#!/usr/bin/env ruby18 -wKU

require "find"

$: << '/Applications/TextMate.app/Contents/SharedSupport/Support/lib/'
$: << '/Library/Application Support/TextMate/Support/lib/'
$: << '~/Library/Application Support/TextMate/Support/lib/'
require "osx/plist"

ROOT_DIRS = if ARGV.empty?
  %w[Bundles Review Disabled\ Bundles].map do |rel|
    File.join(File.dirname(__FILE__), *%W[.. .. #{rel}])
  end
else
  ARGV
end

uuids = Hash.new { |ids, id| ids[id] = Array.new }

puts "Searching bundles ..." if $DEBUG
ROOT_DIRS.each do |root_dir|
  Find.find(root_dir) do |path|
    if File.file?(path) and
       File.extname(path) =~ /.*\.(tm[A-Z][a-zA-Z]+|plist)\Z/
      begin
        plist = File.open(path) { |io| OSX::PropertyList.load(io) }
        if uuid = plist["uuid"]
          uuids[uuid] << path
        else
          warn "Could not find a UUID for #{path}." if $DEBUG
        end
      rescue
        warn "Skipping #{path} due to #{$!.message}." if $DEBUG
      end
    end
  end
end

duplicates = uuids.select { |_, paths| paths.size > 1 }
if duplicates.empty?
  puts "No duplicates found." if $DEBUG
else
  puts
  puts "UUID Duplicates:"
  puts
  duplicates.each do |uuid, paths|
    puts uuid, paths.map { |path| "  #{path}" }
    puts
  end
  exit 1
end
