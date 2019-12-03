#!/usr/bin/env ruby18

# class XcodeApplication < Object
# 	attr_accessor :active_project
# 	
# 	def initialize
# 		active_project = xcode_command "name of project of active project document"
# 	end
# end

$debug = false

class XcodeProject < Object
	attr_accessor :name
	
	def initialize(project = nil)
		if project and project.match(/\.xcodeproj\/?$/)
			xcode_command ["tell application \"Finder\"",
								"set proj_path to POSIX file #{q project}",
								"set proj to item proj_path",
								"end tell",
								"open proj"] unless xcode_command("project #{q project_name_from_path(project)}").include? "project"
			xcode_command "project #{q project_name_from_path(project)}"
			self.name = "project #{q project_name_from_path(project)}"
		elsif project
			self.name = "project #{q project}"
		else
			self.name = "project of active project document"
		end
	end
	
	def project_name_from_path(path)
		path.match(/^.*\/(.*?)\.xcode(proj)?/)[1]
	end
end

class XcodeTarget < Object
	attr_accessor :name
	
	def initialize(target = nil)
		if target
			self.name = "target #{q target}"
		else
			self.name = "active target"
		end
	end
	
	def full_name
		self.name + " of #{$project.name}"
	end
	
	def list
		list = xcode_command "name of build files of #{full_name}"
		list.split(", ").sort.join $/
	end
	
	def add(file)
		command = <<APPLESCRIPT
	set file_path to #{q file} as POSIX file as alias
	tell #{$project.name}
		tell root group
			make new file reference with properties {full path:file_path, name:name of (info for file_path)}
		end tell
		set compile_id to (id of compile sources phase of #{name})
		add file reference (name of (info for file_path)) to (build phase id compile_id) of #{name}
	end tell
APPLESCRIPT
		xcode_command command.split($/)
		"A #{file}"
	end
end


def xcode_command(message)
	command = "osascript -e \"tell application \\\"Xcode\\\"\""
	message.each do |line|
		command += " -e \"#{shell_escape line}\""
	end
	command += " -e \"end tell\""
	if $debug
		print command
		print $/
	end
	`#{command}`.strip
end

def q(what)
	'"' + what.strip + '"'
end

def shell_escape(text)
	text.gsub /"/, '\\"'
end

def usage
	usage = <<OUT
Usage: $ xcd project=foo [target=bar] (add=file[...]|list)
OUT
end

# $app = XcodeApplication.new

# project = ARGV[project_index = ARGV.index "project" + 1] || app.active_project
# target = ARGV[target_index = ARGV.index "target" + 1] || project.active_target

$files = []

ARGV.each do |arg|
	case arg
		when /project=(.*?)$/
			$project = XcodeProject.new $1
		when /target=(.*?)$/
			$target = XcodeTarget.new $1
		when /add=(.*?)$/
			$files << $1
		when "list"
		else
			print usage
			exit
	end
end

unless $project
	print usage
	exit
end
# p $project
# p $project.name
# exit
$target = XcodeTarget.new unless $target

print $target.list if ARGV.include? "list"


$files.each do |file|
	print $target.add(file) + $/
end