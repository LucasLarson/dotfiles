require 'erb'
require File.dirname(__FILE__) + '/../model/info'
require ENV['TM_SUPPORT_PATH'] + '/lib/web_preview'
require ENV['TM_SUPPORT_PATH'] + '/lib/escape'

module Subversion
  class Info
    
    class HTMLView
      TEMPLATE = ERB.new(<<-HTML
        <div class="subversion">
          <% entries.each_with_index do |e,i| %>
            <p<%= ' class="alternate"' if ((i + 1) % 2) == 0 %>>
              <h3><%= e.path %> (r<%= e.revision %>)</h3>
              <table class="blame">
                <tr><th>URL in Repository</th></tr>
                <tr><td style="white-space: normal;"><a href="<%= e.url %>"><%= e.url %></a></td></tr>
              </table>
              <h4>Last Changed…</h4>
              <table class="blame">
                <tr><th>Revision</th><th>Author</th><th>Date</th></tr>
                <tr><td><%= e.commit.revision %></td><td><%= e.commit.author %></td><td><%= e.commit.date %></td></tr>
              </table>
              <h4>Repository…</h4>
              <table class="blame">
                <tr><th>URL</th><th>UUID</th></tr>
                <tr><td><a href="<%= e.repository.root %>"><%= e.repository.root %></a></td><td><%= e.repository.uuid %></td></tr>
              </table>
            </p>
          <% end %>
        </div>
      HTML
      )
      
      def initialize(update_result)
        @info = update_result
      end
      
      def render
        html_header("svn info")
        puts TEMPLATE.result(binding)
        html_footer
      end
      
      def entries
        @info.entries
      end
    end
    
  end
end

if __FILE__ == $0
  require 'stringio'
  require 'tempfile'
  require ENV['TM_SUPPORT_PATH'] + '/lib/tm/process'
  $stdout = StringIO.new
  Subversion::Info::HTMLView.new(Subversion::Info::XmlParser.new(STDIN.read).info).render
  Tempfile.open("tm_svn_info_html.html") do |f|
    f.write($stdout.string)
    f.flush
    %x{open -a Safari.app file://#{f.path}}
    sleep 1
  end
end