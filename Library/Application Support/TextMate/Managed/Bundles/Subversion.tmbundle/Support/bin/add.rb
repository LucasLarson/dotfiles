require "#{ENV['TM_SUPPORT_PATH']}/lib/textmate"
require "#{ENV['TM_BUNDLE_SUPPORT']}/lib/subversion"
require "#{ENV['TM_SUPPORT_PATH']}/lib/ui"

unless ARGV.empty?
  base = Pathname.new(ENV['TM_PROJECT_DIRECTORY'] || ENV['TM_DIRECTORY'])
  relative_args = ARGV.collect { |a| Pathname.new(a).relative_path_from(base) }
  Dir.chdir(base) do
    out = Subversion.run("add", Subversion.esc(relative_args))
    TextMate::UI.tool_tip("<strong>svn add</strong><p>#{htmlize out}</p>", :format => :html)
  end
end
