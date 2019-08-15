require "#{ENV['TM_SUPPORT_PATH']}/lib/textmate"
require "#{ENV['TM_BUNDLE_SUPPORT']}/lib/subversion"

unless ARGV.empty?
  base = Pathname.new(ENV['TM_PROJECT_DIRECTORY'] || ENV['TM_DIRECTORY'])
  relargs = ARGV.collect { |e| Pathname.new(e).relative_path_from(base) }
  reldir = TextMate::UI.request_file(:only_directories => true, :directory => base, :title => "Select Destination") do |dir|
    Pathname.new(dir.first).relative_path_from(base)
  end

  if reldir.to_s =~ /^\.\.\//
    TextMate::UI.alert(:critical, "Invalid Move Destination", "The selected destination is not part of the project.")
    exit
  end
  
  Dir.chdir(base.to_s) do
    if relargs.size == 1 
      newname = TextMate::UI.request_string(:title => "Specify File Name", :prompt => "Enter the name of the file at the new destination:", :default => relargs.first.basename.to_s)
      unless newname.nil?
        out = Subversion.run("mv", relargs.first, "#{reldir}/#{newname}")
      end
    else
      out = Subversion.run("mv", *[relargs, reldir].flatten)
    end
    $stdout << out 
  end
end
