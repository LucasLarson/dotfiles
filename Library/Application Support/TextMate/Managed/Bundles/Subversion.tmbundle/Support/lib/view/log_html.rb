require 'erb'
require File.dirname(__FILE__) + '/../model/log'
require File.dirname(__FILE__) + "/../util/status_codes"
require File.dirname(__FILE__) + "/../subversion"
require ENV['TM_SUPPORT_PATH'] + '/lib/web_preview'
require ENV['TM_SUPPORT_PATH'] + '/lib/escape'


module Subversion
  class Log

    class HTMLView
      TEMPLATE = ERB.new(<<-HTML
        <script type="text/javascript" charset="utf-8">
        cat_bin = "<%= e_sh(e_sh(cat)) %>";
        diff_bin = "<%= e_sh(e_sh(diff)) %>";
        repo_url = "<%= e_sh(e_sh(repo_url)) %>";
        
        function didFinishCommand()
        {
          TextMate.isBusy = false;
        }

        function cat(url, rev)
        {
          TextMate.isBusy = true;
          TextMate.system(cat_bin + " --revision=" + rev + " --send-to-mate " + repo_url + url + '@' + rev + " &", didFinishCommand); 
        }

        function diff(url, rev)
        {
          TextMate.isBusy = true;
          TextMate.system(diff_bin + " --revision=" + rev + " --send-to-mate --url --change " + repo_url + url + '@' + rev + " &", didFinishCommand);
        }
        
        function toggle_filelist_display(base_id,show)
        {
          document.getElementById( base_id ).style.display = (show) ? 'block' : 'none';
          document.getElementById( base_id+'_show' ).style.display = (show) ? 'none' : 'inline';
          document.getElementById( base_id+'_hide' ).style.display = (show) ? 'inline' : 'none';
        }

        </script>
        <% ordered_entries.each_with_index do |e,i| %>
        <table class="log <%= 'alternate' if ((i + 1) % 2) == 0 %>">
          <% r = e.rev %>
          <tr><th>Revision:</th><td><%= r %></td></tr>
          <tr><th>Author:</th>  <td><%= e.author %></td></tr>
          <tr><th>Date:</th>    <td><%= e.date %></td></tr>
          <tr><th>Changed Files:</th>
            <td>
              <a id="r<%= r %>_show" href="javascript:toggle_filelist_display('r<%= r %>', true);">show (<%= e.paths.size %>)</a>
              <a id="r<%= r %>_hide" href="javascript:toggle_filelist_display('r<%= r %>', false);" class="hidden">hide</a>
              <ul id="r<%= r %>" class="hidden">
                <% e.paths.each do |path,action| %>
                <li class="<%= ::Subversion::StatusCodes.status(action) %>">
                  <%=  view_link_for path, r, action %>
                </li>
                <% end %>
              </ul>
            </td></tr>
            <tr>
              <th>Message:</th>
              <td class="msg_field">
              <%= (htmlize e.msg).gsub(/\n/, "<br />") %>
              </td>
            </tr>
          </table>
        <% end %>
      HTML
      )

      def initialize(base, file, log)
        @file = file
        @log = log
        @info = Subversion.info(base, file)
      end

      def render
        html_header(File.basename(@file))
        puts TEMPLATE.result(binding)
        html_footer
      end

      def cat
        ENV['TM_BUNDLE_SUPPORT'] + '/bin/cat.rb'
      end

      def diff
        ENV['TM_BUNDLE_SUPPORT'] + '/bin/diff.rb'
      end

      def repo_url
        @info.entries.first.repository.root
      end
      def ordered_entries
        @log.ordered_entries
      end
            
      def view_link_for(path, rev, action)
        rev = rev - 1 if action == 'D'
        link = "<a href='#' onClick=\"javascript:cat('#{e_sh(e_sh(path))}','#{rev}')\">#{htmlize path}</a>"
        if action == 'M'
          link << " "
          link << "<a href='#' onClick=\"javascript:diff('#{e_sh(e_sh(path))}','#{rev}')\">Show Changes</a>"
        end
        link
      end
    end    

  end
end

if __FILE__ == $0
  require 'stringio'
  require 'tempfile'
  $stdout = StringIO.new
  Subversion::Log::HTMLView.new(Subversion::XmlLogParser.new(STDIN.read).log).render
  Tempfile.open("tm_svn_log_html.html") do |f|
    f.write($stdout.string)
    f.flush
    %x{open -a Safari.app file://#{f.path}}
    sleep 1
  end
end