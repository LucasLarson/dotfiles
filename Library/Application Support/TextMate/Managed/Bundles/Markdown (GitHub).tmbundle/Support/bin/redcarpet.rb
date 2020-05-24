#!/System/Library/Frameworks/Ruby.framework/Versions/Current/usr/bin/ruby
# Usage: markdown-github.rb [<file>...]
# Convert one or more GitHub Flavored Markdown files to HTML and print to
# standard output. With no <file> or when <file> is "-", read GitHub Flavored
# Markdown source text from standard input.

if ARGV.include?("--help")
  File.read(__FILE__).split("\n").grep(/^# /).each do |line|
    puts line[2..-1]
  end
  exit 0
end

require "rubygems"

begin
  require "redcarpet"
  require "pygments"
rescue LoadError
  puts <<-EOS
<p>Please install the Redcarpet and Pygments.rb RubyGems by running the following:</p>

<pre><code>/usr/bin/gem install --user redcarpet pygments.rb</code></pre>
EOS
  exit 0
end

class PygmentsSmartyHTML < Redcarpet::Render::HTML
  include Redcarpet::Render::SmartyPants

  def block_code(code, language)
    language ||= "text"
    Pygments.highlight(code, :lexer => language)
  rescue
    Pygments.highlight(code, :lexer => "text")
  end
end

def checkbox_html(checked)
  "<li><input type='checkbox' #{"checked" if checked} style='margin-right:0.5em;'/>"
end

def markdown(text)
  options = {
    :filter_html     => true,
    :safe_links_only => true,
    :with_toc_data   => true,
    :hard_wrap       => true,
  }
  renderer = PygmentsSmartyHTML.new(options)
  extensions = {
    :no_intra_emphasis   => true,
    :tables              => true,
    :fenced_code_blocks  => true,
    :autolink            => true,
    :strikethrough       => true,
    :space_after_headers => true,
  }
  html = Redcarpet::Markdown.new(renderer, extensions).render(text)
  html.gsub!("<li>[ ]", checkbox_html(false))
  html.gsub!("<li>[x]", checkbox_html(true))
  html
end

puts "<style>#{Pygments.css(:style => "colorful")}</style>"
puts markdown(ARGF.read)
