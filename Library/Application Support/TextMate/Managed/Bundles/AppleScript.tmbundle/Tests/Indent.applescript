-- Single line tell and if shuldn't cause an indent or fold
if 1 is 2 then beep
tell the application "Finder" to beep

-- forcewrapped single line shoud indent without folding -- NOT POSSIBLE
tell the application ¬
	"Finder" to beep

-- Normal tell & if should fold & indent
tell the application "Finder"
	beep
end tell

if 1 is 2 then
	beep
else if 1 is 5
	say "cool"
else
	beep
end if

