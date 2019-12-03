#!/usr/bin/env ruby18

require ENV["TM_SUPPORT_PATH"] + "/lib/tm/executor"
require ENV["TM_SUPPORT_PATH"] + "/lib/tm/save_current_document"
require ENV["TM_SUPPORT_PATH"] + "/lib/ui"
require "shellwords"
require "pstore"
require 'pathname'

class JavaMatePrefs
  @@prefs = PStore.new(File.expand_path( "~/Library/Preferences/com.macromates.textmate.javamate"))
  def self.get(key)
    @@prefs.transaction { @@prefs[key] }
  end
  def self.set(key,value)
    @@prefs.transaction { @@prefs[key] = value }
  end
end

TextMate::Executor.make_project_master_current_document

cmd = ["#{ENV['TM_BUNDLE_SUPPORT']}/bin/java_compile_and_run.sh"]
cmd << ENV['TM_FILEPATH']
script_args = []
if ENV.include? 'TM_JAVAMATE_GET_ARGS'
  prev_args = JavaMatePrefs.get("prev_args")
  args = TextMate::UI.request_string(:title => "JavaMate", :prompt => "Enter any command line options:", :default => prev_args)
  JavaMatePrefs.set("prev_args", args)
  script_args = Shellwords.shellwords(args)
end
cwd = Pathname.new(Pathname.new(Dir.pwd).realpath)

package = nil
File.open(ENV['TM_FILEPATH'], "r") do |f|
  while (line = f.gets)
    if line =~ /^\s*package\s+([^\s;]+)/
      package = $1
      break
    end
  end
end

#cmd << package if package
ENV["TM_JAVA_PACKAGE"] = package

TextMate::Executor.run(cmd, :version_args => ["--version"], :script_args => script_args)
