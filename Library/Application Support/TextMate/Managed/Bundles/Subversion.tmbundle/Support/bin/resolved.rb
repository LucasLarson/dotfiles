require "#{ENV['TM_SUPPORT_PATH']}/lib/textmate"
require "#{ENV['TM_BUNDLE_SUPPORT']}/lib/subversion"
require "#{ENV['TM_SUPPORT_PATH']}/lib/ui"

unless ARGV.empty?
  TextMate::UI.tool_tip("<strong>svn resolved</strong><p>#{htmlize Subversion.run("resolved", ARGV)}</p>", :format => :html)
end
