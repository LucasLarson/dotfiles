#!/usr/bin/env ruby18
# Copyright 2005 Chris Thomas. All rights reserved.
# MIT license; share and enjoy.
require 'pathname'

module XcodeProjectSearch

	# FIXME Assumes the directory only contains one Xcode project
	def XcodeProjectSearch.project_in_dir(path)
		entries = Dir.entries(path)
	
		# Explicit precedence: Xcode >= 2.1, then Xcode <= 2.0, then Project Builder
		# This allows you to keep old projects around but always builds using the
		# newest Xcode.
		project = entries.detect {|entry| entry =~ /.xcodeproj$/} ||
			entries.detect {|entry| entry =~ /.xcode$/} ||
			entries.detect {|entry| entry =~ /.pbproj$/}

		project ? path + "/" + project : nil
	end
	
	def XcodeProjectSearch.project_by_walking_up( start_dir = Dir.pwd )
		project		= nil
		save_dir	= start_dir
		current_dir	= save_dir

		Dir.chdir( current_dir )
		begin
			until current_dir == '/'
				project = project_in_dir(current_dir)
				break unless project.nil?
			
				Dir.chdir '..'
				current_dir = Dir.pwd
			end
		ensure
			Dir.chdir(save_dir)
		end
	
		project
	end

	def XcodeProjectSearch.find_project
		xcode_project		= ENV['TM_XCODE_PROJECT']
		active_file_dir		= ENV['TM_DIRECTORY']
		active_project_dir	= ENV['TM_PROJECT_DIRECTORY']
		
		# Allow paths relative to TM_PROJECT_DIRECTORY
		if xcode_project && !xcode_project[%r{^/}]
		  xcode_project = active_project_dir + "/" + xcode_project
	  end
	
		# user-specified TM_XCODE_PROJECT overrides everything else
		if (xcode_project.nil?) or (xcode_project.empty?)
			
			# If we have an open file in a saved project (or a scratch project)
			if (not active_project_dir.nil?) and (not active_project_dir.empty?)
				xcode_project = project_in_dir(active_project_dir)
			end
				
			# If we didn't find an xcode project in the project directoy, search from current dir and upwards
			if (xcode_project.nil?) or (xcode_project.empty?)
				xcode_project = project_by_walking_up(active_file_dir)
			end

		end
	
		xcode_project
	end

end

#
# if this file is executed as a shell command (i.e. not serving as a Ruby library via require),
# print the file name and cd to the parent directory of the Xcode project so that xcodebuild
# works properly.
#
if __FILE__ == $0
	project = XcodeProjectSearch.find_project
	unless project.nil?
		Dir.chdir File.dirname(project)
		puts project
	end
end
