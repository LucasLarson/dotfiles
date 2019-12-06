#!/usr/bin/env ruby18
#
# This command searches around the caret/selection for the nearest quotes and expands
# the name to the full quoted text, then tries to open the file at the path described
# by that text.
#
# $Id: open_include.py 3196 2006-05-01 21:43:54Z aparajita $
#
# encoding: utf-8


line = ENV['TM_CURRENT_LINE']
selected = ENV['TM_SELECTED_TEXT']
col = Integer(ENV['TM_LINE_INDEX']) - 1  # Start at character before caret

# Search backward until we find a non-word character or line start
first = col

first.downto(0) do |first|
	c = line[first, 1]

	if c =~ %r|[[:alnum:]_\-./]|
		next
	end

	# The start should be one past the first nonvalid character
	first += 1
	break
end

# Search backward until we find a non-word character or line start
last = col + 1

last.upto(line.length - 1) do |last|
	c = line[last, 1]

	if c =~ %r|[[:alnum:]_\-./]|
		next
	end

	last -= 1
	break
end

if last - first == 0
	print "No filename found"
	exit(206)
else
	filename = File.join(ENV['TM_DIRECTORY'], line[first..last])
	
	if test(?f, filename)
		system("mate '#{filename}'")
	else
		print "File not found"
		exit(206)
	end
end
