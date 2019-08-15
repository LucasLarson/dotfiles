require 'erb'
require File.dirname(__FILE__) + '/../model/update_result'
require ENV['TM_SUPPORT_PATH'] + '/lib/web_preview'

module Subversion
  class UpdateResult
    
    class HTMLView
      
      TEMPLATE = ERB.new(<<-HTML
        <table class="status">
            <tr>
                <th colspan="3">Status</th>
                <th>File</th>
            </tr>
            <% items.each_with_index do |f,i| %>
            <tr<%= ' class="alternate"' if ((i + 1) % 2) == 0 %>>
                <td class="status_col <%= f.item_status %>"><%= f.item_code %></td>
                <td class="status_col <%= f.property_status %>"><%= f.property_code %></td>
                <td class="status_col <%= f.lock_status %>"><%= f.lock_code %></td>
                <td class="file"><a href="<%= f.tm_url %>" class="pathname"><%= f.relative_path %></a></td>
            </tr>
            <% end %>
        </table>
      HTML
      )
      
      def initialize(update_result)
        @update_result = update_result
      end
      
      def render
        html_header("Updated to r#{@update_result.revision}")
        puts TEMPLATE.result(binding)
        html_footer
      end
      
      def items
        @update_result.items
      end
    end
    
  end
end

if __FILE__ == $0
  result = Subversion::UpdateResult.new("/", 100)
  result.add_item("M", "M", "M", "test.txt")
  result.add_item("M", "M", "M", "test2.txt")
  view = Subversion::UpdateResult::HTMLView.new(result)
  puts view.render
end