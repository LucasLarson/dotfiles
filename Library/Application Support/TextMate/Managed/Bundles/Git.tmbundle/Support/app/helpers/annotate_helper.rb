module AnnotateHelper
  def selected_line_range
    lines = parse_selection_string(ENV['TM_SELECTION']).flatten
    [lines.min, lines.max]
  end
  
  # Parses the selection string and includes an array containing the lines
  # selected in the document
  def parse_selection_string(str)
    str.split('&').map do |range|
      if range =~ /(\d+)(?::(\d+))?(?:\+\d+)?(?:([-x])(\d+)(?::(\d+))?(?:\+\d+)?)?/
        l1, l2, c1, c2 = $1.to_i, ($4 ? $4.to_i : nil), ($2 || 1).to_i, ($5 || 1).to_i
        l1, l2, c1, c2 = l2, l1, c2, c1 if l2 && (l1 > l2 || l1 == l2 && c1 > c2)

        case $3
          when 'x'
            [ l1, l2 ]
          when '-'
            l2 -= 1 if c2 == 1
            [ l1, l2 ]
          else
            [ l1, l1 ]
        end
      else
        abort "unsupported selection string syntax: ‘#{range}’"
      end
    end
  end
end