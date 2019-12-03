#!/usr/bin/env ruby18

require "#{ENV['TM_SUPPORT_PATH']}/lib/osx/plist"

result = %x{defaults read com.apple.Xcode PBXApplicationwideBuildSettings}
if $? == 0
	print OSX::PropertyList::load(result)["OBJROOT"].to_s
	exit(0)
else
	exit($?)
end