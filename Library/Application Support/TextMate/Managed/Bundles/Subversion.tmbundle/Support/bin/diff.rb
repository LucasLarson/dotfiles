#!/usr/bin/env ruby18

require 'optparse'
require 'tempfile'
require 'pathname'

require "#{ENV['TM_SUPPORT_PATH']}/lib/ui"
require "#{ENV['TM_SUPPORT_PATH']}/lib/exit_codes"
require "#{ENV['TM_SUPPORT_PATH']}/lib/tm/process"
require "#{ENV['TM_BUNDLE_SUPPORT']}/lib/operation_helper/revision_chooser"

base = nil
revision = 'BASE'
change = false
send_to_mate = false
is_url = false
external = false

optparser = OptionParser.new do |optparser|
  optparser.banner = "Usage: #{File.basename(__FILE__)} [options] [files]"
  optparser.separator ""
  optparser.separator "Specific options:"

  optparser.on("--base=PATH", "If present, paths will be displayed to the user relative to this") do |b|
    base = b
  end
  
  optparser.on("--send-to-mate", "If present, the diff will be sent to `mate` instead of STDOUT") do |s|
    send_to_mate = s
  end
  
  optparser.on("--external", "Use if the script is being called from outside TextMate") do |s|
    external = s
  end

  optparser.on("--url", "") do |u|
    is_url = u
  end

  optparser.on("--revision=REVISION", "") do |r|
    revision = r
  end

  optparser.on("--change", "") do |c|
    change = c
  end
end

optparser.parse!

files = ARGV

unless files.empty?
  base = ENV['TM_PROJECT_DIRECTORY'] || ENV['TM_DIRECTORY'] || nil if base.nil?
    
  if ["?", ":"].member? revision
    if files.length > 1
      TextMate::UI.alert(:warning, "Multiple Selection Not Permitted", "When comparing aribtrary revisions, only one file or folder can be selected.", "OK") 
      exit
    end
    chooser = Subversion::RevisionChooser.new(files.first)
    revision = (revision == '?') ? chooser.revision : chooser.range
    exit 0 if revision.nil?
  end
  
  diff = ""
  if is_url
    diff = Subversion.diff_url(files, revision, :change => change)
  else
    diff = Subversion.diff_files(base,revision,files)
  end
  
  if diff.empty?
    TextMate::UI.alert(:warning, "No differences to show", "The selected files/revisions are identical.", "OK")
    TextMate.exit_discard unless external
  elsif diff.split("\n").size == 2 # An external differ was used and we just got the header svn puts on
    TextMate.exit_discard unless external
  else
    if send_to_mate
      tmp = Tempfile.new(files.map{ |f| File.basename(f.sub(/\@.+$/, '')) }.join('-'), ENV['TMPDIR'] || '/tmp')
      tmp.write diff
      tmp.flush
      out, err = TextMate::Process.run("mate", "-w", tmp.path)
      abort err if $? != 0
    else
      external ? $stdout << diff : TextMate.exit_create_new_document(diff)
      
    end
  end
end