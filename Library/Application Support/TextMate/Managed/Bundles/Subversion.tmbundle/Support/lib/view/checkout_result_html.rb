require 'erb'
require ENV['TM_SUPPORT_PATH'] + '/lib/web_preview'

module Subversion
  class CheckoutResult

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

      def initialize(checkout_result)
        @checkout_result = checkout_result
      end

      def render
        html_header("Checked out revision #{@checkout_result.revision}")
        puts TEMPLATE.result(binding)
        html_footer
      end

      def items
        @checkout_result.items
      end
    end

  end
end