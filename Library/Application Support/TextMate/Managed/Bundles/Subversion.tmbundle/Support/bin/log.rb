require "#{ENV['TM_SUPPORT_PATH']}/lib/exit_codes"
require "#{ENV['TM_BUNDLE_SUPPORT']}/lib/subversion"
require "#{ENV['TM_BUNDLE_SUPPORT']}/lib/view/log_html"

abort "The `log` command only accepts one working copy path" if ARGV.size > 1

file = Subversion.esc(ARGV.first)
result = Subversion.log(file, :verbose => true)
view = Subversion::Log::HTMLView.new((ENV['TM_PROJECT_DIRECTORY'] || ENV['TM_DIRECTORY'] || Dir.pwd), file, result)
view.render
TextMate.exit_show_html