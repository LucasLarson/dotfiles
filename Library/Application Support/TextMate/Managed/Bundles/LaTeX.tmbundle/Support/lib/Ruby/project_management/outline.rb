# -- Imports -------------------------------------------------------------------

require 'erb'

require ENV['TM_SUPPORT_PATH'] + '/lib/exit_codes.rb'
require ENV['TM_SUPPORT_PATH'] + '/lib/web_preview.rb'
require ENV['TM_BUNDLE_SUPPORT'] + '/lib/Ruby/latex.rb'

# -- Functions -----------------------------------------------------------------

# Add the given path to the path of the current master file.
#
# = Arguments
#
# [filepath] The path that should be added to the master path
#
# = Output
#
# The function returns a string containing a filepath.
#
# = Example
#
#  doctest: Add the path 'input/references_input' to the current master path
#  >> ENV['TM_FILEPATH'] = 'Tests/TeX/references.tex'
#  >> join_with_master_path('input/references_input').end_with? (
#     'Tests/TeX/input/references_input.tex')
#  => true
def join_with_master_path(filepath)
  master = LaTeX.master(ENV['TM_LATEX_MASTER'] || ENV['TM_FILEPATH'])
  path = File.expand_path(filepath, File.dirname(master))
  "#{path}#{'.tex' unless path.match(/\.tex$/) || File.exist?(path)}"
end

# Show an outline for the current tex document.
#
# The function shows a clickable HTML view for the current tex document.
def show_outline
  file = LaTeX.master(ENV['TM_LATEX_MASTER'] || ENV['TM_FILEPATH'])
  file = if file.nil? then STDIN
         else File.expand_path(file, File.dirname(ENV['TM_FILEPATH']))
         end
  outline = Outline.outline_from_file(file)
  html_header 'LaTeX Document Outline', 'LaTeX'
  puts(outline)
  html_footer
end

# -- Class ---------------------------------------------------------------------

# ================
# = Show Outline =
# ================

# This class represent a section of a tex document.
#
# A section acts the same way as a strings. The class implements additional
# methods that allows us to take the order of a section into account.
class Section < String
  # rubocop: disable Style/ClassVars
  @@parts = %w[part chapter section subsection subsubsection paragraph
               subparagraph]
  # rubocop: enable Style/ClassVars

  # Get the number of levels from the current to the given section.
  #
  # The returned value specifies how many levels it takes to get from the
  # current section to the given section.
  #
  # = Arguments
  #
  # [other] The other section that should be compared to this one.
  #
  # = Output
  #
  # The function returns a number specifying how many sections down (positive
  # value), or up (negative value) it takes to get to the given section.
  #
  #  doctest: The section 'section' is two levels down starting from 'part'
  #  >> Section.new('part').levels_to('section')
  #  => 2
  #
  #  doctest: The section 'part' is two levels up starting from 'paragraph'
  #  >> Section.new('paragraph').levels_to('part')
  #  => -5
  def levels_to(other)
    @@parts.index(other) - @@parts.index(self)
  end

  # Get the section with the smallest level in a list of strings.
  #
  # = Arguments
  #
  # [part_list] A list containing section strings.
  #
  # = Output
  #
  # The function returns a new section.
  #
  # = Examples
  #
  #  doctest: Get the smallest section from a list of strings.
  #  >> Section.smallest_part(['paragraph', 'section', 'part', 'subsection'])
  #  => 'part'
  def self.smallest_part(part_list)
    Section.new @@parts[part_list.map { |part| @@parts.index(part) }.min]
  end
end

# -- Module --------------------------------------------------------------------

# Various code used to show an outline — table of contents — for a tex document.
module Outline
  # Get an HTML outline from the given tex file.
  #
  # = Arguments
  #
  # [filepath] The path to the file for which we want to get an HTML outline.
  #
  # = Output
  #
  # The function returns a string containing HTML lists that reference the
  # different part of the given document.
  def self.outline_from_file(filepath)
    outline_points_to_html(outline_points(filepath))
  end

  class <<self
    private

    PART = '(part|chapter|section|subsection|subsubsection|paragraph|' \
           'subparagraph)\*?'.freeze
    COMMENT = '(?:%.*\n[ \t]*)?'.freeze
    OPTIONS = '(?>\[(.*?)\])'.freeze
    ARGUMENT = '\{([^{}]*(?:\{[^}]*\}[^}]*?)*)\}'.freeze

    PART_REGEX = /\\#{PART}#{COMMENT}(?:#{OPTIONS}|#{ARGUMENT})/.freeze
    INCLUDE_REGEX = /\\(?:input|include)#{COMMENT}(?>\{([^}#]*)\})/.freeze
    NON_COMMENT_REGEX = /^([^%]+$|(?:[^%]|\\%)+)(?=%|$)/.freeze

    # Get the text stored in and a URL referencing +filename+.
    def content_url(filename, ref_filename = nil, ref_line = nil,
                    ref_linenumber = nil)
      if filename.is_a?(String)
        [File.read(filename), "url=file://#{ERB::Util.url_encode(filename)}&"]
      else
        [filename.read, '']
      end
    rescue StandardError => error
      TextMate.exit_show_tool_tip("#{ref_filename}:#{ref_linenumber} " \
                                  "“#{ref_line}”\n\t#{error.message}")
    end

    # Try to get a outline point — containing url, line number, section and
    # the text of the section — from a single line of text.
    def outline_point_from_line(line, url, linenumber)
      return unless line.match(PART_REGEX)

      [url, linenumber, Regexp.last_match[1],
       Regexp.last_match[2] || Regexp.last_match[3]]
    end

    # Try to get outline points from a file referenced in a line of text.
    def outline_points_from_line(line, linenumber, filename)
      if line.match(INCLUDE_REGEX)
        outline_points(join_with_master_path(Regexp.last_match[1]), filename,
                       line, linenumber)
      else
        []
      end
    end

    # Get all the outline points contained in +filename+.
    def outline_points(filename, ref_filename = nil, ref_line = nil,
                       ref_linenumber = nil)
      data, url = content_url(filename, ref_filename, ref_line, ref_linenumber)
      points = []
      data.split("\n").each_with_index do |line, linenumber|
        next unless line.match(NON_COMMENT_REGEX)

        points << outline_point_from_line(Regexp.last_match[1], url,
                                          linenumber + 1)
        points += outline_points_from_line(line, linenumber + 1, filename)
      end
      points.compact
    end

    # Convert a list of outline points to HTML.
    def outline_points_to_html(points)
      smallest_part = Section.smallest_part(points.map { |_, _, part, _| part })
      last_part = smallest_part
      items = points.map do |filepath, line, part, title|
        levels = last_part.levels_to(part)
        last_part = Section.new(part)
        "#{levels > 0 ? '<ol>' * levels : '</ol>' * levels.abs}<li>
          <a href=\"txmt://open?#{filepath}line=#{line}\">#{title}</a></li>"
      end
      "<ol>#{items.join("\n")}</ol>" +
        '</ol>' * last_part.levels_to(smallest_part).abs
    end
  end
end
