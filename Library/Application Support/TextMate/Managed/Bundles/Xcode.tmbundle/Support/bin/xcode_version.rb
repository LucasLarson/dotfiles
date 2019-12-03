#!/usr/bin/env ruby18
# Copyright 2005 Chris Thomas. All rights reserved.
# MIT license; share and enjoy.

class Xcode
	
	def Xcode.supports_configurations?
		
		unless defined? @@xcode2dot1_or_later
			version_str = %x{ xcodebuild 2>/dev/null -version }
			version_match = /DevToolsCore-(\d+).\d+;/.match(version_str)
			@@xcode2dot1_or_later = (version_match != nil &&
										version_match.length > 0 &&
										version_match[1].to_i >= 620)
		end

		@@xcode2dot1_or_later
	end
	
	def Xcode.preferences
		global_path = "#{ENV['HOME']}/Library/Preferences/com.apple.Xcode.plist"
		open(global_path) { |io| OSX::PropertyList.load io } rescue { }
	end
	
end


if __FILE__ == $0 then
	puts(Xcode.supports_configurations? ? 1 : 0).to_s
end
