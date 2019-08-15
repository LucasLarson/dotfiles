#!/usr/bin/env ruby18

require 'optparse'
require File.dirname(__FILE__) + "/../lib/subversion"
require "#{ENV['TM_SUPPORT_PATH']}/lib/tm/process"
require "#{ENV['TM_BUNDLE_SUPPORT']}/lib/operation_helper/revision_chooser"

revision = 'HEAD'
send_to_mate = false

optparser = OptionParser.new do |optparser|
  optparser.banner = "Usage: #{File.basename(__FILE__)} [options] [url]"
  optparser.separator ""
  optparser.separator "Specific options:"
  
  optparser.on("--send-to-mate", "If present, the file will be opened with `mate` instead of sent to STDOUT") do |s|
    send_to_mate = s
  end

  optparser.on("--revision=REVISION", "") do |r|
    revision = r
  end

end

optparser.parse!
target = ARGV.first
revision = Subversion::RevisionChooser.new(target).revision.to_s if revision == "?"
content = Subversion.cat(target, revision)
  
if send_to_mate
  tmp = File.new((ENV['TMPDIR'] || '/tmp') + "/" + File.basename(target.sub(/\@.+$/, '')), "w")
  tmp.write content
  tmp.flush
  out, err = TextMate::Process.run("mate", "-w", tmp.path)
  abort err if $? != 0
else
  $stdout << content
end