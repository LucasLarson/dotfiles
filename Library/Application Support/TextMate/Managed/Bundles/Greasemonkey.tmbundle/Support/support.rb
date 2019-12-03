# Support stuff for Greasemonkey bundle commands for TextMate
# By Henrik Nyh <http://henrik.nyh.se>.
# Free to modify and redistribute non-commercially with due credit.


InstalledScript = Struct.new(:name, :filename)


class AppleScript
	def self.ensure_gui_scripting(mess)
		%{
			tell application "System Events"
				if not UI elements enabled then
					do shell script "osascript \\"#{ENV['TM_BUNDLE_SUPPORT']}/bin/enable_assistive_devices.app\\" \\"#{mess}\\""
					return
				end if
			end tell
		}
	end
end


class Greasemonkey

	class Script
		attr_reader :file_path, :file_name, :file_lines, :file_data, :name, :namespace, :description, :includes, :excludes, :xml_name, :xml_namespace
		def initialize(config)
			@config = config
			@file_path = ENV['TM_FILEPATH']
			@file_name = File.basename(@file_path) if @file_path
			
			# These values are only present if the command input is "Entire document"!
			@file_lines = STDIN.readlines
			@file_data = @file_lines.join
			
			declaration_value = /[ \t]+(\S.*?)\s*[\r\n]/
			@name = ($1 if @file_data =~ /@name#{declaration_value}/)
			@namespace = ($1 if @file_data =~ /@namespace#{declaration_value}/)
			@description = ($1 if @file_data =~ /@description#{declaration_value}/) || ""
			@includes = @file_data.scan(/@include#{declaration_value}/).flatten
			@excludes = @file_data.scan(/@exclude#{declaration_value}/).flatten
			@includes = ["*"] if @includes.empty?
			if installed?
				xml_script = @config.xml.root.elements["Script[@filename='#{@file_name}']"]
				@xml_name = xml_script.attributes["name"]
				@xml_namespace = xml_script.attributes["namespace"] 
			end
		end
		
		def installed?
			return false unless @config.exist?
			is_in_config_dir = File.dirname(@file_path.to_s) == @config.directory
			is_in_config_xml = @config.xml.root.elements["Script[@filename='#{@file_name}']"]
			return (is_in_config_dir and is_in_config_xml)
		end

		# The Greasemonkey extension will actually accept anything, but let's keep things pretty.
		def ensure_valid
			abort "This script does not have a @name and a @namespace!" unless (@name and @namespace)
		end

		def ensure_saved
			abort "This script is not saved!" if (@file_path.nil? or @file_path.empty?)
		end

		def ensure_installed
			abort "This file is not an installed script!" unless installed?
		end

		def avoid_installed
			abort "This script is already installed!" if installed?
		end
	end
	
	
	class Config
		attr_reader :directory, :file_name
		def initialize
			firefox_support = "#{ENV['HOME']}/Library/Application Support/Firefox"
			profiles_file = "#{firefox_support}/profiles.ini"
			return unless File.exist?(profiles_file)
			@directory = "#{firefox_support}/#{$1}/gm_scripts" if File.open(profiles_file).read =~ /Path=(\S+)\s*(?:Default=1|\Z)/
			@file_name = "#{@directory}/config.xml" if @directory
		end
		def file_lines
			File.open(@file_name).to_a
		end
		def exist?
			@file_name and File.exist?(@file_name)
		end
		def ensure_existence
			abort "Could not locate Firefox directory!" unless exist?
		end
		def xml
			self.ensure_existence
			
			require "rexml/document"
			xml_data = REXML::Document.new File.new(@file_name)
			
			if block_given?
				yield(xml_data)
				self.xml = xml_data
			else
				xml_data
			end
		end
		def xml=(data)
			data.write File.open(@file_name, 'w')
		end
	end
	
	class Preferences
		FILE = "#{ENV['HOME']}/Library/Preferences/com.macromates.textmate.gmbundle.plist"
		def self.[](key)
			prefs = self.load
			value = prefs[key.to_s]
			if value=="" then nil else value end
		end
		def self.[]=(key, value)
			merge!({key => value})
			value
		end
		def self.merge!(hash, options={})
			prefs, new_prefs = self.load, {}
			
			# Remove anything we can't keep. reject, don't delete_if, or we'll modify by reference.
			hash = hash.reject { |k,v| not Array(options[:keep]).map { |e| e.to_sym }.include?(k.to_sym) } if options[:keep]
			# Ensure to_plist gets string keys and non-nil values.
			hash.each_pair { |k,v| new_prefs[k.to_s] = v || "" }
			
			prefs.merge!(new_prefs)
			File.open(FILE, "w") { |f| f.print(prefs.to_plist) }
			prefs
		end
		private
		def self.load
			OSX::PropertyList.load(File.new(FILE)) rescue {}
		end
	end


	def initialize
		@config = Greasemonkey::Config.new
		@script = Greasemonkey::Script.new(@config)
	end

end