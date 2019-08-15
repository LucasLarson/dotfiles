require "#{ENV['TM_SUPPORT_PATH']}/lib/exit_codes"
require "#{ENV['TM_BUNDLE_SUPPORT']}/lib/subversion"
require "#{ENV['TM_BUNDLE_SUPPORT']}/lib/view/blame_html"

abort "The `blame` command only accepts one working copy path" if ARGV.size > 1
base = Pathname.new(ENV['TM_PROJECT_DIRECTORY'] || ENV['TM_DIRECTORY'] || Dir.pwd)
Subversion::Blame::HTMLView.new(Subversion.blame(base, ARGV), ENV['TM_LINE_NUMBER'].to_i).render
TextMate.exit_show_html