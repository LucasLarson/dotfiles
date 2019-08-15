require 'erb'
require ENV['TM_SUPPORT_PATH'] + '/lib/web_preview'

module Subversion
  class Blame

    class HTMLView

      TEMPLATE = ERB.new(<<-HTML
        <div class="subversion">
          <table class="blame">
            <tr>
              <th>line</th>
              <th class="revhead">rev</th>
              <th>user</th>
              <th class="codehead">code</th>
            </tr>
            <% lines do |num,line| %>
            <tr title="<%= path.log.entries[line.revision].msg %>">
              <td class="linecol"><%= htmlize num %></td>
              <td class="revcol<%= " current_line" if highlight_line? %>"><%= htmlize line.revision %></td>
              <td class="namecol<%= " current_line" if highlight_line? %>"><%= htmlize line.author %></td>
              <td class="codecol<%= " current_line" if highlight_line? %><%= " alternate" if alternate? %>"><%= htmlize line.content %></td>
            </tr>
            <% end %>
          </table>
        </div>
      HTML
      )

      def initialize(blame, highlight_line)
        @blame = blame
        @highlight_line = highlight_line
        @previous_revision = nil
        @lines_at_rev_count = 1
      end

      def render
        html_header(path.path)
        puts TEMPLATE.result(binding)
        html_footer
      end

      def highlight_line
        @highlight_line
      end

      def lines(&block)
        @alternate = true
        path.lines.keys.sort.each do |num|
          @num = num
          @line = path.lines[num]
          @alternate = (not @alternate) if @previous_revision != @line.revision
          block.call(@num,@line)
          @previous_revision = @line.revision
        end
      end

      def highlight_line?
        @num == @highlight_line
      end

      def alternate?
        @alternate
      end

      def path
        @blame.paths.first
      end
    end

  end
end