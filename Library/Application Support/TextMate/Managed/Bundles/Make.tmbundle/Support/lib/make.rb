#!/usr/bin/env ruby18

require ENV["TM_SUPPORT_PATH"] + "/lib/tm/executor"
require ENV["TM_SUPPORT_PATH"] + "/lib/tm/save_current_document"
require ENV["TM_SUPPORT_PATH"] + "/lib/escape"

TM_MAKE = e_sh(ENV['TM_MAKE'] || 'make')
TextMate::Executor.make_project_master_current_document

def find_makefile_path ()
  candidates = [ ENV["TM_MAKE_FILE"], File.expand_path('Makefile', ENV["TM_PROJECT_DIRECTORY"]) ]

  dir = ENV["TM_DIRECTORY"]
  while dir && dir != ENV["TM_PROJECT_DIRECTORY"] && dir != "/" && dir[0] == ?/
    candidates << File.join(dir, "Makefile")
    dir = File.dirname(dir)
  end

  candidates.find { |path| path && File.file?(path) }
end

def perform_make(target = nil)
  path = find_makefile_path
  if path.nil?
    puts "No Makefile found.<br>"
    puts "Set <tt>TM_MAKE_FILE</tt> in Preferences → Variable."
    exit
  end

  dir, makefile = File.split(path)

  flags = ["-w"]
  flags << "-f" + makefile
  flags << ENV["TM_MAKE_FLAGS"] unless ENV["TM_MAKE_FLAGS"].nil?
  flags << target unless target.nil?

  dirs = [dir, ENV['TM_PROJECT_DIRECTORY']]
  TextMate::Executor.run(TM_MAKE, flags, :chdir => dir, :verb => "Making", :noun => (target || "default"), :use_hashbang => false) do |line, type|
    if line =~ /^g?make.*?: Entering directory `(.*?)'$/ and not $1.nil? and File.directory?($1)
      dirs.unshift($1)
      ""
    elsif line =~ /^g?make.*?: Leaving directory `(.*?)'$/ and not $1.nil? and File.directory?($1)
      dirs.delete($1)
      ""
    elsif line =~ /^\s*((.*?)\((\d+),(\d+)\):)(\s*(?:warning|error)\s+.*)$/ and not $1.nil?
      # smcs (C#)
      make_txmt_link(dirs, $2, $3, $4, $1, $5)
    elsif line =~ /^((.*?):(?:(\d+):)?(?:(\d+):)?)(.*?)$/ and not $1.nil?
      # GCC, et al
      make_txmt_link(dirs, $2, $3, $4, $1, $5)
    end
  end
end

def make_txmt_link(dirs, file, lineno, column, title, message)
  path = dirs.map{ |dir| File.expand_path(file, dir) }.find{ |path| File.file? path }
  unless path.nil?
    unless lineno.nil?
      value = (message =~ /^\s*(error|warning|note):/ ? $1 : "warning") + ":#{message}"
      args = [ "--line=#{lineno}:#{column || '1'}", "--set-mark=#{value}" ]
      args << path if path != ENV['TM_FILEPATH'] || !ENV.has_key?('TM_FILE_IS_UNTITLED')
      system(ENV['TM_MATE'], *args)
    end

    parms =  [    "url=file://#{e_url path}" ]
    parms << [   "line=#{lineno}"            ] unless lineno.nil?
    parms << [ "column=#{column}"            ] unless column.nil?
    info = file.gsub('&', '&amp;').gsub('<', '&lt;').gsub('"', '&quot;')
    "<a href=\"txmt://open?#{parms.join '&'}\" title=\"#{info}\">#{title}</a>#{htmlize message}<br>\n"
  end
end
