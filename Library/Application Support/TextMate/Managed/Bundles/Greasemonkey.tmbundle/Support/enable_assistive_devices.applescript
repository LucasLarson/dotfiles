on run argv
	
	-- NOTE: This is the UNCOMPILED script. Compile into .app after making changes.
	
	set customMessage to item 1 of argv
	
	-- Determine which of Firefox or TM is frontmost (no other possibilities are relevant, yet)
	-- Note that Firefox always seems to returns "true" for "frontmost", even when it's not
	set frontmostApp to (application "Firefox")
	tell application "TextMate"
		if frontmost then set frontmostApp to (application "TextMate")
	end tell
	
	try
		tell frontmostApp to set answer to button returned of (display dialog customMessage & return & return & "This command relies on the GUI scripting architecture of Mac OS X which is currently disabled." & return & return & "You can activate it by selecting the checkbox \"Enable access for assistive devices\" in the Universal Access preference pane." buttons {"OK", "Open Preference Pane"} default button 2 with icon 1)
	on error number -128
		-- User cancelled
	end try
	
	if answer is "Open Preference Pane" then
		tell application "System Preferences"
			activate
			set current pane to pane "com.apple.preference.universalaccess"
			display dialog "Activate GUI Scripting by selecting the checkbox \"Enable access for assistive devices\" in the Universal Access preference pane." buttons {"OK"} default button 1 with icon 1
		end tell
	end if
end run