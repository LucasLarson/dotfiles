require "#{ENV['TM_SUPPORT_PATH']}/lib/exit_codes"
require "#{ENV['TM_BUNDLE_SUPPORT']}/lib/subversion"
require "#{ENV['TM_BUNDLE_SUPPORT']}/lib/view/info_html"

# TODO deal with non versioned files better

base = Pathname.new(ENV['TM_PROJECT_DIRECTORY'] || ENV['TM_DIRECTORY'] || Dir.pwd)
relative_paths = ARGV.map { |f| Pathname.new(f).relative_path_from(base) }
result = Subversion.info(base.to_s, *relative_paths)
if result.entries.empty?
  TextMate::UI.alert(:warning, "Info not available", "Make sure you have selected versioned files.", "OK")
else
  view = Subversion::Info::HTMLView.new(result)
  view.render
  TextMate.exit_show_html
end