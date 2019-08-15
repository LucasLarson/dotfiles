require "#{ENV['TM_SUPPORT_PATH']}/lib/exit_codes"
require "#{ENV['TM_BUNDLE_SUPPORT']}/lib/subversion"
require "#{ENV['TM_BUNDLE_SUPPORT']}/lib/view/status_html"

status_listing = Subversion.status(*ARGV)
if status_listing.entries.empty?
  TextMate::UI.alert(:warning, "No Modified Files", "None of the selected files are modified.", "OK")
  TextMate.exit_discard
else
  view = Subversion::Status::HTMLView.new((ENV['TM_PROJECT_DIRECTORY'] || ENV['TM_DIRECTORY'] || Dir.pwd), status_listing)
  view.render
  TextMate.exit_show_html
end
