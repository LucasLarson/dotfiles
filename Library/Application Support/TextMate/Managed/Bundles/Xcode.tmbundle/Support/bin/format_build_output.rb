# encoding: utf-8

#
# xcodebuild output parser for TextMate
# chris@cjack.com
#
# Copyright 2005,2007 Chris Thomas. All rights reserved.
#
# MIT license. 
#

$bundle				= ENV['TM_BUNDLE_SUPPORT']
$support			= ENV['TM_SUPPORT_PATH']

require "#{$support}/lib/web_preview"
require "#{$bundle}/bin/xcode_version"
require 'cgi'

#
# Formatted HTML output consists of <div>s with this structure:
#
#  <div class="section">[ShowHide innerNNN][SectionName]
#   <div class="inner" id="innerNNN">
# 		...content...
#   </div>
#  </div>
#
# Other "section" divs may nest inside "inner" divs.
#

class Formatter

	attr_accessor :div_nesting_count
	attr_accessor :next_section_id
	attr_accessor :next_inner_id
	attr_accessor :current_section_class

	def initialize
		@current_section_class = 'section_unadorned'
		@div_nesting_count = 0
		@next_section_id = "sect00001"
		@next_inner_id = "in00001"
	end
	
	#
	# Entrypoints for build parser
	#
	def start
		windowTitle = ENV['TM_XCODE_WINDOW_TITLE'] || 'Build With Xcode'
		emit_raw(html_head(:title => windowTitle, :sub_title => "Xcode"))
	end
	
	def start_new_section(title = nil)
		end_open_sections
		emit_start_section(title.nil? ? nil : html_escape(title))
	end
	
	# target_name -- start a new target section
	def target_name(verb, name, style = nil)
		end_open_sections
		
		title = %Q{<span class="action">#{html_escape(verb.capitalize)}</span> <span class="name">#{html_escape(name)}</span>}
		
		unless style.nil?
			if Xcode.supports_configurations? then
				title += (" with configuration ")
			else
				title += (" with build style ")
			end
		
			title += %Q{<span class="name">#{html_escape(style)}</span><br />}
		end
		
		visibility = title.include?("BUILD LEGACY TARGET") ? :hide : :show
		emit_start_section(title, :css_suffix => 'target', :visibility => visibility)
	end
	
	def file_compiled( verb, file )
		end_current_section if @current_section_class != 'section_target'
		title = %Q{<span class="method">#{html_escape(verb)}</span> <span class="name">#{html_escape(file)}</span>}
		emit_start_section(title, :css_suffix => 'build_command', :visibility => :hide)
	end
	
	def build_noise(text)
		return if text.strip.empty?
		
#		emit_raw("<p></b>section_class is: #{@current_section_class}</b></p>")
		if @current_section_class == 'section_unadorned'
			# start a new target section (so we can display the text)
			end_open_sections
			emit_start_section(nil, :css_suffix => 'target', :visibility => :show)
		end
		emit_raw("<code>" + html_escape(text) + "</code>")
	end
	
	# GCC sometimes outputs pertinent text preceding an "error:"  "warning:" line,
	# we need to hang onto that text until we know whether it's an error or a warning.
	def message_prefix( line )
		@message_prefix ||= ''
		@message_prefix << (html_escape(line) + "<br>")
	end

	# error messages
	# cssclass may be nil
	def error_message( cssclass, path, line, error_desc )
		cssclass = cssclass.downcase
		cssclass = case cssclass
			when ""
				"error"
			when "message"
				"info"
			else
				cssclass
		end
		
		# Append to existing error content
		unless current_section_class_is(cssclass)
			end_current_section
			emit_start_section(%Q{<span class="message_title">#{cssclass}</span>}, :css_suffix => cssclass, :visibility => :show)
		end
		
#		@mup.new_div!(cssclass) { @mup.h2(cssclass) }

		if defined?(@message_prefix) and (not @message_prefix.empty?)
			emit_raw(@message_prefix)
			@message_prefix = ''
		end
		emit_raw("<p>" + txtmt_link(path, line) + ":" + html_escape(error_desc) + "</p>")

	end

	def success(message)
		end_open_sections
		
		title = html_escape(message.split(" ").collect { |word| word.capitalize }.join(" "))
		emit_start_section(%Q{<span class="message_title">#{title}</span>}, :css_suffix => 'info', :visibility => :hide)
		
		play_sound(ENV['TM_SUCCESS_SOUND'] || 'Hero')
	end	

	def failure
		end_open_sections
		emit_start_section(%Q{<span class="message_title">Build Failed</span>}, :css_suffix => 'error', :visibility => :hide)

		play_sound(ENV['TM_ERROR_SOUND'] || 'Basso')
	end

	def complete
		end_open_sections
		
		footer =<<-HTML
			</div>
		</body>
		</html>
HTML
		emit_raw(footer)
	end

	# Running the build result

	def run_executable( name )
		end_open_sections

		# button to clear the run log
		clear_buttom_html = %Q{<input type="button" value="Clear Log" onclick="javascript:clearElement('console_output_b')" />}

		emit_start_section("</h2>Running #{html_escape(name)}</h2> #{clear_buttom_html}", :inner_content_id => 'console_output', :css_suffix => 'console', :visibility => :show)
		
  	end

	def executable_output( line )
		emit_raw('<div class="console">')
		emit_raw(wrap_tag('code', html_escape(line) + wrap_tag('br')))
		emit_raw('</div>')
	end

	def executable_error( line )
		emit_raw('<div class="console_error">')
		emit_raw(wrap_tag('code', html_escape(line) + wrap_tag('br')))
		emit_raw('</div>')
	end	

	def executable_HTML( line )
		emit_raw('<div class="console">')
		emit_raw(line + wrap_tag('br'))
		emit_raw('</div>')
	end
	
 private

	def html_escape(text)
		CGI.escapeHTML(text)
	end

	 def play_sound(name)
	   return if ENV['TM_MUTE']

	   src = [ ENV['TM_SUPPORT_PATH'], "#{ENV['HOME']}/Library", '/Library', '/Network/Library', '/System/Library' ]
	   src.each do |e|
	     Dir.chdir(e + '/Sounds') do |dir|
	       if sound = Dir.glob("#{name}.*").first
	         sound = "#{dir}/#{sound}"
	         play  = ENV['TM_SUPPORT_PATH'] + '/bin/play'
	         %x{ #{e_sh play} #{e_sh sound} &>/dev/null & }
	         return
	       end
	     end rescue nil
	   end

	   STDERR << "Could not locate sound named ‘#{name}’\n"
	 end

	def txtmt_link( path, line_number )
		line_number = 1 if line_number.nil?
		%Q{<a href="txmt://open?url=file://#{path}&line=#{line_number}">#{html_escape(File.basename(path) + ":" + line_number.to_s)}</a>}
	end

	def end_current_section
		2.times {emit_close_div} if (@div_nesting_count > 0)
	end

	def end_open_sections
		div_count = @div_nesting_count
		div_count.times { emit_close_div }
	end
	
	def emit_raw(html)
		print html
		$stdout.flush
	end	

	def wrap_tag(tag, html = nil)
		if html.nil?
			"<#{tag} />"
		else
			"<#{tag}>#{html}<#{tag}>"
		end
	end

	def emit_raw_tag(tag, html = nil)
		print wrap_tag(tag, html)
		$stdout.flush
	end	
	
	def current_section_class_is(css_suffix)
		(@current_section_class == ('section_' + css_suffix))
	end
	
	# title should be HTML
	def emit_start_section(title, options = {:visibility => :show_always})
		
		css_suffix	= options[:css_suffix] || 'section_unadorned'
		visibility	= options[:visibility]		
		
		section_id = @next_section_id
		inner_id = options[:inner_content_id] || @next_inner_id
		
		emit_raw(%Q{<div class="section_#{css_suffix}" id="#{section_id}">})

		# add show/hide toggle prior to title
		# Use Unicode triangle symbols for disclosure triangle (for now -- later, use actual graphics and AJAX and fancy stuff)
		
		style_for_inner_div = ''
		
		unless visibility == :show_always
			hide_if_hidden_style = (visibility == :hide) ? "display: none;" : "";
			show_if_hidden_style = (visibility == :hide) ? "" : "display: none;";

			style_for_inner_div =  %Q{style="#{hide_if_hidden_style}"}
			showhide_html = <<END
			<span class="showhide">
			<a href="javascript:hideElement('#{inner_id}')" id="#{inner_id + '_h'}" style="#{hide_if_hidden_style}">\&\#x25BC;</a>
			<a href="javascript:showElement('#{inner_id}')" id="#{inner_id + '_s'}" style="#{show_if_hidden_style}">\&\#x25B6;</a>
			</span>
END
			emit_raw(showhide_html)
		end
		
		emit_raw(title) unless title.nil?
		emit_raw(%Q{<div class="inner" id="#{inner_id}_b" #{style_for_inner_div}>})
		
		@div_nesting_count += 2
		@current_section_class = 'section_' + css_suffix
		
		@next_section_id = section_id.succ
		@next_inner_id = inner_id.succ
	end
	
	def emit_close_div
		emit_raw("</div>")
		@div_nesting_count -= 1
	end
end


# On with the show
load($bundle + "/bin/parse_build.rb")

