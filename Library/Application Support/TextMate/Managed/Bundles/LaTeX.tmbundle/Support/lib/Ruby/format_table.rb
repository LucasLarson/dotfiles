#!/usr/bin/env ruby

# rubocop: disable Lint/MissingCopEnableDirective
# rubocop: disable Metrics/AbcSize, Metrics/MethodLength

##
# Format a latex tabular environment.
#
# = Arguments
#
# [table_content] A string containing the tabular environment
#
# = Output
#
# The function returns a string containing a properly formatted latex table.
#
# = Examples
#
# doctest: Reformat a table containing only one line
#
#   >> reformat 'First Item & Second Item'
#   => "First Item & Second Item\\\\"
#
# doctest: Reformat a table containing an escaped `&` sign
#
#   >> output = reformat('First Item & Second Item\\\\He \& Ho & Hi')
#   >> expected =
#    'First Item & Second Item\\\\
#      He \& Ho &          Hi\\\\'
#   >> output.eql? expected
#   => true
#
# doctest: Reformat a table containing empty cells
#
#   >> output = reformat(' & 2\\\\\\hline & 4 \\\\ Turbostaat & 6')
#   >> output.eql? ['           & 2\\\\',
#                   '\\hline',
#                   '           & 4\\\\',
#                   'Turbostaat & 6\\\\'].join("\n")
#   => true
#
# doctest: Reformat a table containing manual spacing
#
#   >> output = reformat('1 & [2]\\\\[1cm]\hline Three & Four')
#   >> output.eql? ['     1 &  [2]\\\\[1cm]',
#                   '\\hline',
#                   ' Three & Four\\\\'].join("\n")
#   => true
#
# doctest: Reformat a table containing \rule commands
#
#   >> output = reformat(
#     '  \\toprule Head 1 & Head 2 & Head 3\\\\ \\midrule Column 1 &
#      Column 2 & Column 3\\\\ \bottomrule')
#   >> output.eql? ['\\toprule',
#                   '     Head 1 &   Head 2 &   Head 3\\\\',
#                   '\\midrule',
#                   '   Column 1 & Column 2 & Column 3\\\\',
#                   '\\bottomrule'].join("\n")
#   => true
def reformat(table_content)
  before_table = table_content.slice!(/^.*?\}\s*\n/)
  table_content.gsub!(/\\(?:hline|(?:(?:top|mid|bottom)rule))/, '\0\\\\\\\\')
  lines = table_content.split('\\\\')

  # Check for manual horizontal spacing of the form `[space]` e.g.: `[1cm]`
  space_markers = lines.map do |line|
    line.slice!(/\s*\[\s*(\d*\.\d|\d+\.?)\s*(?:pt|mm|cm|in|em|ex|mu)\s*\]/)
  end

  cells = lines.map { |line| line.split(/[^\\]&|^&/).map(&:strip) }
  max_number_columns = cells.map(&:length).max
  widths = []
  max_number_columns.times do |column|
    widths << cells.reduce(0) do |maximum, line|
      column >= line.length ? maximum : [maximum, line[column].length].max
    end
  end
  pattern = widths.map { |width| "%#{width}s" }.join(' & ')
  (before_table ? before_table.chomp + "\n" : '') + \
    cells.map.each_with_index do |line, index|
      if line.length <= 1 then (line.join '')
      else format(pattern, *line) + "\\\\#{space_markers[index + 1]}"
      end
    end.join("\n")
end
