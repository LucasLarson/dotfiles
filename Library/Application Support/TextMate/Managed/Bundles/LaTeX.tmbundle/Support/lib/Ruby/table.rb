# -- Imports -------------------------------------------------------------------

require ENV['TM_SUPPORT_PATH'] + '/lib/escape'
require ENV['TM_SUPPORT_PATH'] + '/lib/exit_codes'
require ENV['TM_SUPPORT_PATH'] + '/lib/osx/plist'
require ENV['TM_BUNDLE_SUPPORT'] + '/lib/Ruby/indent'

# -- Class ---------------------------------------------------------------------

# This class represents a LaTeX table.
# rubocop: disable Lint/MissingCopEnableDirective
# rubocop: disable Metrics/ClassLength
class Table
  # This function initializes a new LaTeX table.
  #
  # The default dimensions of the table are determined by reading the current
  # selection. If there is no selection, then the values will be read via a pop
  # up window.
  #
  # = Arguments
  #
  # [rows] The number of table rows
  # [columns] The number of table columns
  # [full_table] Specify if this table represents a full table or only a tabular
  #              environment
  def initialize(rows = nil, columns = nil, full_table = true)
    @rows = rows
    @columns = columns
    @full_table = full_table
    @rows, @columns, @full_table = self.class.read_parameters unless
      @rows && @columns
    @i1 = indent
    @i2 = @i1 * 2
    @array_header_start = '\textbf{'
    @array_header_end = '}'
    @insertion_points_header = @full_table ? 2 : 0
  end

  # This function returns a string representation of the current table.
  #
  # = Output
  #
  # The function returns a string containing LaTeX code for the table.
  #
  # = Examples
  #
  #  doctest: Check the representation of a small table
  #
  #  >> table = Table.new(2, 2)
  #  >> i1 = indent(1)
  #  >> i2 = indent(2)
  #  >> start = ["\\begin{table}[htb!]",
  #              "#{i1}\\caption{${1:Caption}}",
  #              "#{i1}\\label{table:${2:label}}",
  #              "#{i1}\\centering"]
  #  >> ending = ["#{i2}\\bottomrule",
  #               "#{i1}\\end{tabular}",
  #               "\\end{table}"]
  #  >> middle = [
  #       "#{i1}\\begin{tabular}{ll}",
  #       "#{i2}\\toprule",
  #       "#{i2}\\textbf{${3:Header 1}} & \\textbf{${4:Header 2}}\\\\\\\\",
  #       "#{i2}\\midrule",
  #       "#{i2}             ${5:r2c1} &              ${6:r2c2}\\\\\\\\"]
  #  >> table_representation = (start + middle + ending).join("\n")
  #  >> table.to_s == table_representation
  #  => true
  #
  #  doctest: Check the representation of a tiny table
  #
  #  >> table = Table.new(1, 1)
  #  >> middle = [
  #       "#{i1}\\begin{tabular}{l}",
  #       "#{i2}\\toprule",
  #       "#{i2}\\textbf{${3:Header 1}}\\\\\\\\"]
  #  >> table_representation = (start + middle + ending).join("\n")
  #  >> table.to_s == table_representation
  #  => true
  #
  #  doctest: Check the representation of a small tabular environment
  #
  #  >> table = Table.new(2, 3, false)
  #  >> table_representation = [
  #       "\\begin{tabular}{lll}",
  #       "#{i1}${1:r1c1} & ${2:r1c2} & ${3:r1c3}\\\\\\\\",
  #       "#{i1}${4:r2c1} & ${5:r2c2} & ${6:r2c3}\\\\\\\\",
  #       "\\end{tabular}"].join("\n")
  #  >> table.to_s == table_representation
  #  => true
  def to_s
    if @full_table
      [header, array_header, @rows <= 1 ? nil : array, footer].compact
    else
      ["\\begin{tabular}{#{'l' * @columns}}", array, '\\end{tabular}']
    end.join("\n")
  end

  private

  def header
    "\\begin{table}[htb!]\n" \
    "#{@i1}\\caption{\${1:Caption}}\n" \
    "#{@i1}\\label{table:\${2:label}}\n" \
    "#{@i1}\\centering\n" \
    "#{@i1}\\begin{tabular}{#{'l' * @columns}}\n" \
    "#{@i2}\\toprule"
  end

  def footer
    "#{@i2}\\bottomrule\n#{@i1}\\end{tabular}\n\\end{table}"
  end

  def array_header(insertion_point = @insertion_points_header)
    @i2 + Array.new(@columns) do |c|
      @array_header_start + \
        "${#{insertion_point += 1}:#{array_header_text(c)}}" + \
        @array_header_end
    end.join(' & ') + '\\\\\\\\' + (@rows >= 2 ? "\n#{@i2}\\midrule" : '')
  end

  def array_header_text(column)
    "Header #{column + 1}"
  end

  def array_header_length(column)
    array_header_text(column).length + @array_header_start.length + \
      @array_header_end.length
  end

  def array
    rows = @rows - (@full_table ? 1 : 0)
    insertion_point = @full_table ? @insertion_points_header + @columns : 0
    indentation = @full_table ? @i2 : @i1
    create_array(rows, indentation, insertion_point)
  end

  # rubocop: disable Metrics/AbcSize
  def create_array(rows, indentation, insertion_point)
    Array.new(rows) do |row|
      row += @full_table ? 2 : 1
      padding = ' ' * (@rows.to_s.length - row.to_s.length) unless @full_table
      indentation + Array.new(@columns) do |c|
        text = "r#{row}c#{c + 1}"
        padding = ' ' * (array_header_length(c) - text.length) if @full_table
        "#{padding}${#{insertion_point += 1}:#{text}}"
      end.join(' & ') + '\\\\\\\\'
    end.join("\n")
  end

  class <<self
    def read_parameters
      if ENV.key?('TM_SELECTED_TEXT')
        parse_parameters_text(ENV['TM_SELECTED_TEXT'])
      else
        read_parameters_ui
      end
    end

    def read_parameters_ui
      dialog = e_sh ENV['DIALOG']
      defaults = e_sh("{ latexTableRows = '2'; latexTableColumns = '2';" \
                      '  latexTableTabular = 1; }')
      nib = e_sh(ENV['TM_BUNDLE_SUPPORT']) + '/nibs/CreateTable'
      result_plist = `#{dialog} -d #{defaults} -cm #{nib}`
      values = OSX::PropertyList.load(result_plist)['result']
      TextMate.exit_discard if values.nil?
      parse_parameters_ui(values['rows'], values['columns'],
                          values['returnArgument'])
    end

    def parse_parameters_ui(rows, columns, tabular_only)
      [parse_parameter_table('rows' => rows),
       parse_parameter_table('columns' => columns),
       !tabular_only]
    end

    def parse_parameter_table(parameter)
      value = parameter.values[0]
      name = parameter.keys[0]
      number = value.to_i
      raise RangeError if number < 1 || number > 100

      number
    rescue RangeError
      TextMate.exit_show_tool_tip("“#{value}” is not a valid value for the " \
                                  "number of #{name}.\n" \
                                  'Please use a number between 1 and 100.')
    end

    def parse_parameters_text(result)
      one_upto_hundred = '([1-9]\d?|100)'
      rows_default = 2
      m = /^(?:#{one_upto_hundred}\D+)?#{one_upto_hundred}\s*(t)?$/.
          match(result.to_s)
      TextMate.exit_show_tool_tip(usage_text(rows_default, 100, 100)) if m.nil?
      [m[1] ? m[1].to_i : rows_default, m[2].to_i, m[3].nil?]
    end

    def usage_text(rows_default, rows_max, columns_max)
      "USAGE: [#rows] #columns [t] \n\n" \
      "#rows: Number of table rows (Default: #{rows_default}, " \
      "Maximum: #{rows_max})\n" \
      "#columns: Number of table columns (Maximum: #{columns_max})\n" \
      't: Create a tabular environment only'
    end
  end
end
