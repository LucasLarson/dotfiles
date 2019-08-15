require "#{ENV['TM_SUPPORT_PATH']}/lib/textmate"
require "#{ENV['TM_BUNDLE_SUPPORT']}/lib/subversion"

unless ARGV.empty?
  if ARGV.size > 1
    TextMate::UI.alert(:critical, "Multiple Files Selected", "Only one file can be renamed at a time.")
  else
    base = Pathname.new(ENV['TM_PROJECT_DIRECTORY'] || ENV['TM_DIRECTORY'])
    source = Pathname.new(ARGV.first).relative_path_from(base)
    newname = TextMate::UI.request_string(:title => "Specify File Name", :prompt => "Enter the new name of the file:", :default => source.basename.to_s)
    unless newname.nil?
      Dir.chdir(base.to_s) do
        $stdout << Subversion.run("mv", source, "#{source.parent}/#{newname}")
      end
    end
  end
end
