--#!/usr/bin/osascript
-- The line above is Leopard only

on run argv
	
	set LogPath to item 1 of argv
	set WindowTitle to item 2 of argv
	
	tell application "Terminal"
		activate
		with timeout of 1800 seconds
			do script with command "tail -f " & LogPath
			tell window 1
				set title displays shell path to false
				set title displays window size to false
				set title displays device name to true
				set title displays file name to true
				set title displays custom title to true
				set custom title to WindowTitle
				set number of columns to 80
				set number of rows to 20
			end tell
		end timeout
	end tell
	
end run
