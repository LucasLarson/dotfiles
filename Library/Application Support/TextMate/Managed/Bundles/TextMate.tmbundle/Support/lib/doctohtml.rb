# By Brad Choate -- http://bradchoate.com/

$: << ENV['TM_SUPPORT_PATH'] + '/lib'
require "textmate"

# Provides CSS-friendly variations of common Mac fonts that you
# may use in TextMate. Feel free to edit these to your liking...
FONT_MAP = {
	/\bcourier\b/i => 'Courier, "MS Courier New"',
	/\bbitstream.*mono\b/i => '"Bitstream Vera Sans Mono"',
	/\bandale\b/i => '"Andale Mono"',
	/\bDejaVuSansMono\b/i => '"DejaVu Sans Mono"'
}

def load_theme
  return OSX::PropertyList.load(File.open(ENV['TM_CURRENT_THEME_PATH']))
end

def to_rgba(color)
	colors = color.scan /^#(..)(..)(..)(..)/
	r = colors[0][0].hex
	g = colors[0][1].hex
	b = colors[0][2].hex
	a = colors[0][3].hex
	return "rgba(#{r}, #{g}, #{b}, #{ format '%0.02f', a / 255.0 })"
end

def generate_stylesheet_from_theme(theme_class = nil)
	theme_class = '' if theme_class == nil
	require "#{ENV['TM_SUPPORT_PATH']}/lib/osx/plist"

	unless theme_plist = load_theme
		print "Could not locate your theme file!"
		abort
	end

	theme_comment = theme_plist['comment']
	theme_name = theme_plist['name']
	theme_class.replace(theme_name)
	theme_class.downcase!
	theme_class.gsub!(/[^a-z0-9_-]/, '_')
	theme_class.gsub!(/_+/, '_')

	font_name = `"$TM_QUERY" --setting fontName`.chomp || 'Menlo-Regular'
	font_size = (`"$TM_QUERY" --setting fontSize`.chomp || 12).to_s
	font_size.sub! /\.\d+$/, ''

	FONT_MAP.each do | font_re, font_alt |
		if (font_re.match(font_name))
			font_name = font_alt
			break
		end
	end

	font_name = '"' + font_name + '"' if font_name.include?(' ') &&
		!font_name.include?('"')

	theme_styles = ''
	body_fg = ''
	body_bg = ''
	selection_bg = ''
	pre_selector = "pre.textmate-source.#{theme_class}"

	theme_plist['settings'].each do | setting |
		if (!setting['name'] and setting['settings'])
			body_bg = setting['settings']['background'] || '#ffffff'
			body_fg = setting['settings']['foreground'] || '#000000'
			selection_bg = setting['settings']['selection']
			body_bg = to_rgba(body_bg) if body_bg =~ /#.{8}/
			body_fg = to_rgba(body_fg) if body_fg =~ /#.{8}/
			selection_bg = to_rgba(selection_bg) if selection_bg && selection_bg =~ /#.{8}/
			next
		end
		next unless setting['name'] and setting['scope']
		theme_styles << "/* " + setting['name'] + " */\n"
		scope_name = setting['scope']
		scope_name.gsub! /(^|[ ])-[^ ]+/, '' # strip negated scopes
		scope_name.gsub! /\./, '_' # change inner '.' to '_'
		scope_name.gsub! /(^|[ ])/, '\1.'
		scope_name.gsub! /(^|,\s+)/m, '\1' + pre_selector + ' '
		theme_styles << "#{scope_name} {\n"
		if (color = setting['settings']['foreground'])
			color = to_rgba(color) if color =~ /#.{8}/
			theme_styles << "\tcolor: " + color + ";\n"
		end
		if (style = setting['settings']['fontStyle'])
			theme_styles << "\tfont-style: italic;\n" if style =~ /\bitalic\b/i
			theme_styles << "\ttext-decoration: underline;\n" if style =~ /\bunderline\b/i
			theme_styles << "\tfont-weight: bold;\n" if style =~ /\bbold\b/i
		end
		if (color = setting['settings']['background'])
			color = to_rgba(color) if color =~ /#.{8}/
			theme_styles << "\tbackground-color: " + color + ";\n"
		end
		theme_styles << "}\n\n"
	end

	if (selection_bg)
		# currently, -moz-selection doesn't appear to support alpha transparency
		# so, i'm not assigning it until it does.
		selection_style = "#{pre_selector} ::selection {
	background-color: #{selection_bg};
}"
	else
		selection_style = ""
	end

	return <<EOT
/* Stylesheet generated from TextMate theme
 *
 * #{theme_name}
 * #{theme_comment}
 *
 */

/* Mostly to improve view within the TextMate HTML viewer */
body {
	margin: 0;
	padding: 0;
}

pre.textmate-source {
	margin: 0;
	padding: 0 0 0 2px;
	font-family: #{font_name}, monospace;
	font-size: #{font_size}px;
	line-height: 1.3em;
	word-wrap: break-word;
	white-space: pre;
	white-space: pre-wrap;
	white-space: -moz-pre-wrap;
	white-space: -o-pre-wrap;
}

pre.textmate-source.#{theme_class} {
	color: #{body_fg};
	background-color: #{body_bg};
}

pre.textmate-source .linenum {
	width: 75px;
	padding: 0.1em 1em 0.2em 0;
	color: #888;
	background-color: #eee;
}
pre.textmate-source.#{theme_class} span {
   padding-top: 0.2em;
   padding-bottom: 0.1em;
}
#{selection_style}
#{theme_styles}
EOT
end

def detab(str, width)
	lines = str.split(/\n/)
	lines.each do | line |
		line_sans_markup = line.gsub(/<[^>]*>/, '').gsub(/&[^;]+;/i, '.')
		while (index = line_sans_markup.index("\t"))
			tab = line_sans_markup[0..index].jlength - 1
			padding = " " * ((tab / width + 1) * width - tab)
			line_sans_markup.sub!("\t", padding)
			line.sub!("\t", padding)
		end
	end
	return lines.join("\n")
end

def number(str)
	# number each line of input
	lines = str.split(/\n/)
	n = 0
	lines.each do | line |
		n += 1
		line.gsub!(/^(<\/span>)?/, "\\1<span class='linenum'>#{ sprintf("%5d", n) }</span> ")
	end
	return lines.join("\n")
end

def document_to_html(input, opt = {})
	# Read the source document / selection
	# Convert tabs to spaces using configured tab width
	input = detab(input, (ENV['TM_TAB_SIZE'] || '8').to_i)

	html = ''

	theme_class = ''
  if opt[:include_css]
		# If you declare a 'http://...' link as a TM_SOURCE_STYLESHEET
		# shell variable, that will be used instead of generating a stylesheet
		# based on the current theme.
		if (ENV['TM_SOURCE_STYLESHEET'])
			styles = "\t<link rel=\"stylesheet\" src=\"#{ENV['TM_SOURCE_STYLESHEET']}\" type=\"text/css\">\n"
		else
			styles = generate_stylesheet_from_theme(theme_class)
		end

		# Head block
		html = %{<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN">
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
	<title>#{ ENV['TM_FILENAME'] || 'untitled' }</title>
	<style type="text/css">
#{styles}
	</style>
</head>

<body>}
	end

	# Meat. The poor-man's tokenizer. Fortunately, our input is simple
	# and easy to parse.
	tokens = input.split(/(<[^>]*>)/)
	code_html = ''
	tokens.each do |token|
		case token
		when /^<\//
		  code_html << "</span>"
		when /^<>$/
		  # skip empty tags, resulting from name = ''
		when /^</
		  if token =~ /^<([^>]+)>$/
			  classes = $1.split(/\./)
  			list = []
  			begin
  				list.push(classes.join('_'))
  			end while classes.pop
				code_html << "<span class=\"#{ list.reverse.join(' ').lstrip }\">"
			end
		else
			code_html << token
		end
	end

	code_html = number(code_html) if opt[:line_numbers]

	html << "<pre class=\"textmate-source"
	html << " #{theme_class}" unless theme_class.empty?
	html << "\">#{code_html}</pre>"

  if opt[:include_css]
		# Closing
		html << "\n</body>\n</html>"
	end

	return html
end