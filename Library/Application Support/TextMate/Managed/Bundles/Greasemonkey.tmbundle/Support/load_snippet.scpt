on run args
	set loaded_snippet to read (POSIX file (item 1 of args)) as �class utf8�
	tell app "TextMate" to insert loaded_snippet as snippet true
end run