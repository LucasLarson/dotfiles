def getfontname
	font_name = `"$TM_QUERY" --setting fontName`.chomp || 'Menlo-Regular'
  font_name = '"' + font_name + '"' if font_name.include?(' ') && !font_name.include?('"')
  return font_name
end

def getfontsize
	font_size = (`"$TM_QUERY" --setting fontSize`.chomp || 12).to_s
	font_size.sub!(/\.\d+$/, '')
end