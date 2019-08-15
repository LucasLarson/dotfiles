require 'erb'
require ENV['TM_SUPPORT_PATH'] + '/lib/web_preview'
require File.dirname(__FILE__) + "/../util/status_codes"

module Subversion
  class Status
    
    class HTMLView
      TEMPLATE = ERB.new(<<-HTML
        <div class="subversion">
          <table class="status" border="0">
            <tr>
              <th colspan="5">Status</th>
              <th colspan="4">Actions</th>
              <th>File</th>
            </tr>
            <% entries.each_with_index do |e,i| %>
              <tr<%= ' class="alternate"' if ((i + 1) % 2) == 0 %>>
              <% status = e["wc-status"] %>
              <td class="status_col <%= status["item"] %>"><%= StatusCodes.code(status["item"]) %></td>
              <td class="status_col <%= status["props"] %>"><%= StatusCodes.code(status["props"]) %></td>
              <td class="status_col<%= " locked" if status["wc-locked"] %>"><%= StatusCodes.wc_locked if status["wc-locked"] %></td>
              <td class="status_col<%= " added" if status["copied"] %>"><%= StatusCodes.copied if status["copied"] %></td>
              <td class="status_col<%= " switched" if status["switched"] %>"><%= StatusCodes.switched if status["switched"] %></td>
              <td class=""></td>
              <td class=""></td>
              <td class=""></td>
              <td class=""></td>
              <td class="file_col"> <a href="<%= 'txmt://open?url=file://' + (e_url e["path"]) %>" class="pathname"><%= relativise(e["path"])%></a></td>
              </tr>
            <% end %>
          </table>
        </div>
      HTML
      )
      
      def initialize(basedir, status)
        @basedir = basedir 
        @basedir = @basedir + "/" unless @basedir =~ /\/$/
        @status = status
      end
      
      def status_target
        targets.length > 1 ? "(#{targets.length} selected files)" : File.basename(targets.first['path'])
      end
      
      def render
        html_header("Status for “" + status_target + "”")
        puts TEMPLATE.result(binding)
        html_footer
      end
      
      def targets
        @status.targets
      end
      
      def relativise(path)
        path.sub(/^#{@basedir}/, '')
      end
      
      def entries 
        @status.entries
      end
    end
    
  end
end