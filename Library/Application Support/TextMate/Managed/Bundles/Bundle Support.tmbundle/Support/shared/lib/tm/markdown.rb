module TextMate
	module Markdown
		module_function
		def to_html(str, options = { })
			filters = [ ]
			if ENV.has_key?('TM_MARKDOWN_PRE_FILTER')
				filters += ENV['TM_MARKDOWN_PRE_FILTER'].split(':').reject{ |s| s == '' }
			end
			filters << (ENV.has_key?('TM_MARKDOWN') ? '$TM_MARKDOWN' : '"$TM_SUPPORT_PATH/bin/Markdown.pl"')
			if ENV.has_key?('TM_MARKDOWN_POST_FILTER')
				filters += ENV['TM_MARKDOWN_POST_FILTER'].split(':').reject{ |s| s == '' }
			end

			return str if filters.empty?

			IO.popen(filters.join('|'), 'r+') do |io|
				Thread.new { io << str; io.close_write }
				io.read
			end
		end
	end
end

if $0 == __FILE__
	include TextMate

	ENV.delete('TM_MARKDOWN')
	ENV.delete('TM_MARKDOWN_PRE_FILTER')
	ENV.delete('TM_MARKDOWN_POST_FILTER')
	puts Markdown.to_html("Standard markdown processor") # => <p>Standard markdown processor</p>

	ENV['TM_MARKDOWN'] = "rev"
	puts Markdown.to_html("Custom markdown processor") # => rossecorp nwodkram motsuC

	ENV.delete('TM_MARKDOWN')
	ENV['TM_MARKDOWN_PRE_FILTER'] = "sed -e 's/ /   /g':rev"
	ENV.delete('TM_MARKDOWN_POST_FILTER')
	puts Markdown.to_html("multiple pre filters") # => <p>sretlif   erp   elpitlum</p>

	ENV['TM_MARKDOWN_PRE_FILTER'] = "rev"
	ENV['TM_MARKDOWN_POST_FILTER'] = "tr p '*'"
	puts Markdown.to_html("pre and post filtered") # => <*>deretlif tso* dna er*</*>
end
