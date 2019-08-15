#!/usr/bin/env ruby18

require 'optparse'

require "#{ENV['TM_SUPPORT_PATH']}/lib/ui"
require "#{ENV['TM_SUPPORT_PATH']}/lib/textmate"
require "#{ENV['TM_BUNDLE_SUPPORT']}/lib/operation_helper/commit_transaction"
require "#{ENV['TM_SUPPORT_PATH']}/lib/ui"

output_format = :TM

optparser = OptionParser.new do |optparser|
  optparser.banner = "Usage: #{File.basename(__FILE__)} [options] [files]"
  optparser.separator ""
  optparser.separator "Specific options:"

  output_formats = [:TM, :plaintext]
  optparser.on("--output=TYPE", output_formats, "Select format of output #{output_formats.inspect}.")   do |format|
    output_format = format
  end

  optparser.on_tail("--help", "Display help.") do
    puts optparser
    exit
  end
end

optparser.parse!

unless ARGV.empty?
  transaction = Subversion::CommitTransaction.new(ENV['TM_PROJECT_DIRECTORY'] || ENV['TM_DIRECTORY'] || Dir.pwd, ARGV)
  if transaction.has_mods?
    transaction.show_progress = (output_format == :TM)
    result = transaction.commit
    unless result.nil?
      if result.commits?
        case output_format
        when :plaintext
          puts result.out
        when :TM
          TextMate::UI.tool_tip("<strong>Commit Succeeded</strong><p>#{htmlize result.to_s}</p>", :format => :html)
        end
      end
    end
  else
    header = "No files modified; nothing to commit"
    body = transaction.relative_paths.map{ |path| "• #{path}" }.join("\n")
    case output_format
    when :plaintext
      puts "#{header}\n\n#{body}"
    when :TM
      TextMate::UI.tool_tip("<strong>Commit Failed</strong><p>#{htmlize header}</p>", :format => :html)
    end
  end
end
