require "#{ENV['TM_SUPPORT_PATH']}/lib/tm/htmloutput.rb"

def html_head(options = { })
  TextMate::HTMLOutput.header(options)
end

# compatibility function
def html_header(tm_html_title, tm_html_lang = "", tm_extra_head = "", tm_window_title = nil, tm_fix_href = nil)
  puts html_head(:title => tm_html_title, :sub_title => tm_html_lang, :html_head => tm_extra_head,
                 :window_title => tm_window_title, :fix_href => tm_fix_href)
end

def html_footer
  puts TextMate::HTMLOutput.footer()
end

if __FILE__ == $PROGRAM_NAME
  html_header("Test Title")
  puts "Test Body"
  html_footer
end