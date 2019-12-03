# Various code used by the commands of the LaTeX bundle
#
# Authors:: Charilaos Skiadas, Michael Sheets

# -- Imports -------------------------------------------------------------------

require 'pathname'

require ENV['TM_SUPPORT_PATH'] + '/lib/exit_codes.rb'
require ENV['TM_SUPPORT_PATH'] + '/lib/ui.rb'
require ENV['TM_SUPPORT_PATH'] + '/lib/web_preview.rb'
require ENV['TM_BUNDLE_SUPPORT'] + '/lib/Ruby/indent.rb'
require ENV['TM_BUNDLE_SUPPORT'] + '/lib/Ruby/latex.rb'

# rubocop: disable Style/MixinUsage
include TextMate
# rubocop: enable Style/MixinUsage

# -- Functions -----------------------------------------------------------------

# ===========
# = General =
# ===========

# Display a menu of choices or use the first choice if there is only one.
#
# This function will abort execution if +choices+ is empty or the user does not
# select any of the displayed choices.
#
# = Arguments
#
# [choices] A list of strings. Each string represents a menu item.
def menu_choice_exit_if_empty(choices)
  exit_discard if choices.empty?
  if choices.length > 1
    choice = UI.menu(choices)
    exit_discard if choice.nil?
    choices[choice]
  else
    choices[0]
  end
end

# Filter items according to input.
#
# = Arguments
#
# [input] A string used to filter +items+.
# [items] A list of possible selections.
#
# = Output
#
# A list of filtered items and a boolean value that states if +input+ should be
# replaced or extended.
#
# = Examples
#
#  doctest: Filter a list of simple items
#
#  >> filter_items_replace_input(['item1', 'item2'], '{')
#  => [['item1', 'item2'], false]
#  >> filter_items_replace_input(['item1', 'item2'], '2')
#  => [['item2'], true]
#  >> filter_items_replace_input(['item1', 'item2'], '”~')
#  => [['item1', 'item2'], false]
#
#  doctest: Filter a list of items using case sensitive regex
#
#  >> ENV['TM_LATEX_SEARCH_CASE_SENSITIVE'] = ''
#  >> filter_items_replace_input(['ITem1', 'iTem2', 'item3'], 'iT')
#  => [['iTem2'], true]
def filter_items_replace_input(items, input)
  # Check if we should use the input as part of the choice
  match_input = input.match(/^(?:$|.*[{}~,])/).nil?
  if match_input
    items = if ENV['TM_LATEX_SEARCH_CASE_SENSITIVE']
              items.grep(/#{input}/)
            else
              items.grep(/#{input}/i)
            end
  end
  [items, match_input]
end

# Insert a value based on a selection into the current document.
#
# = Arguments
#
# [selection] A string that is the basis for the output of this function
# [input] The current input/selection of the document
# [replace_input] A boolean that specifies if +input+ should be replaced or not
# [scope] A string that specifies the scope that should be checked. According to
#         this value a new label or citation is inserted into the document
def output_selection(selection, input, replace_input, scope = 'citation')
  if ENV['TM_SCOPE'] =~ /#{scope}/
    if input =~ /^\{\}?/ then print("{#{selection}}")
    elsif input =~ /(,\s*)?(\})?/
      print("#{Regexp.last_match[1]}#{selection}#{Regexp.last_match[2]}")
    else print(selection)
    end
  else
    snippet = reference_snippet(selection, scope)
    exit_insert_snippet("#{replace_input ? '' : input}#{snippet}")
  end
end

# Return a snippet containing a reference to a citation or label.
#
# = Arguments
#
# [reference] A string that contains the reference key for the label/citation.
# [scope] The scope which specifies if the resulting snippet should contain a
#         reference to a citation (scope = 'citation') or an label.
#
# = Output
#
# This function returns a string containing snippet syntax.
#
# = Examples
#
#  doctest: Create a reference to a citation
#
#  >> ENV['TM_LATEX_CITE_SNIPPET'] = '\\\\cite[$1]{CITEKEY}'
#  >> reference_snippet('key', 'citation')
#  => '\\\\cite[$1]{key}'
#
#  doctest: Create a reference to a label
#  >> reference_snippet('key', 'label')
#  => '\\\\${1:ref}{key}'
def reference_snippet(reference, scope)
  if ENV['TM_LATEX_CITE_SNIPPET'] && scope == 'citation'
    ENV['TM_LATEX_CITE_SNIPPET'].gsub('CITEKEY', reference)
  else
    "\\\\${1:#{scope == 'citation' ? 'cite' : 'ref'}}\{#{reference}\}"
  end
end

# Get the path of the current master file.
#
# = Output
#
# A string containing the location of the master file.
def masterfile
  LaTeX.master(ENV['TM_LATEX_MASTER'] || ENV['TM_FILEPATH'])
end

# Return the path to a dropped file relative to the current master file.
def dropped_file_relative_path
  filename = ENV['TM_DROPPED_FILEPATH']
  master = Pathname.new(masterfile)
  master = master.expand_path(ENV['TM_PROJECT_DIRECTORY']) unless
    master.absolute?
  Pathname.new(filename).relative_path_from(master.dirname)
end

# Convert an filepath to a string useable as LaTeX label.
#
# = Arguments
#
# [filepath] The path of the file for which we want to create a label.
#
# = Output
#
# This function returns a string useable as label.
def filepath_to_label(filepath)
  filepath.to_s.gsub(%r{(\.[^.]*$)|(\.\./)}, '').gsub(%r{[/ ]}, '_')
end

# ========================
# = Include Code Listing =
# ========================

# Convert an extension to a language identification for the listings package.
#
# = Arguments
#
# [extension] The extension of a source file without the leading dot.
#
# = Output
#
# The function returns a string containing a language identification.
# rubocop:disable AlignHash
def extension_to_language(extension)
  mapping = { 'ada'  => 'Ada',  'ant'  => 'Ant',  'c'    => 'C',
              'cpp'  => 'C++',  'htm'  => 'HTML', 'html' => 'HTML',
              'java' => 'Java', 'js'   => 'Java', 'json' => 'Java',
              'pl'   => 'Perl', 'php'  => 'PHP',  'py'   => 'Python',
              'rb'   => 'Ruby', 'sh'   => 'sh',   'sql'  => 'SQL',
              'xml'  => 'XML',  'vhdl' => 'VHDL' }
  mapping.key?(extension) ? mapping[extension] : 'Assembler'
end
# rubocop:enable AlignHash

# This function returns a minted listing environment referencing a given file.
#
# = Arguments
#
# [path] The path to the source file
# [label] The label text for the listing
# [extension] A string that specifies the language of the file content
#
# = Output
#
# A string containing a listings environment.
def minted_environment(path, label, language)
  "\\begin{listing}[H]\n" \
  "#{indent(1)}\\caption{\${1:caption}}\n" \
  "#{indent(1)}\\label{lst:\${2:#{label}}}\n" \
  "#{indent(1)}\\\\inputminted{#{language}}{#{path}}\n" \
  '\\end{listing}'
end

# Insert an +lstinputlisting+ command referencing the dropped source file.
def include_code_listing
  path = dropped_file_relative_path
  label = filepath_to_label(path)
  extension = File.extname(path).slice(1..-1)

  if ENV['TM_MODIFIER_FLAGS'] =~ /SHIFT/
    file_type = extension_to_language(extension)
    print("\\\\lstinputlisting[language=\${1:#{file_type}}, tabsize=\${2:4}, " \
         "caption=\${3:caption}, label=lst:\${4:#{label}}]{#{path}}")
  else
    print(minted_environment(path, label, extension))
  end
end

# ================
# = Include File =
# ================

# Insert an include or input item containing a reference to the dropped file.
def include_file
  environment = ENV['TM_MODIFIER_FLAGS'] =~ /OPTION/ ? 'input' : 'include'
  print("\\\\#{environment}{#{dropped_file_relative_path}}")
end

# =================
# = Include Image =
# =================

# Return LaTeX code to reference a figure located at +filepath+.
#
# = Arguments
#
# [filepath] The path to an image that should be included.
def include_figure(filepath)
  "\\\\begin{figure}[\${1|h,t,b,p|}]\n" \
  "  \\\\centering\n" \
  "    \\\\includegraphics[width=\${2:.9\\textwidth}]{#{filepath}}\n" \
  "  \\\\caption{\${3:caption}}\n" \
  "  \\\\label{fig:\${4:#{filepath_to_label(filepath)}}}\n" \
  '\\\\end{figure}'
end

# Include a dropped image in the current document.
def include_image
  path = dropped_file_relative_path
  includegraphics = "\\\\includegraphics[width=\${1:.9\\textwidth}]{#{path}}"
  case ENV['TM_MODIFIER_FLAGS']
  when /OPTION/
    puts("\\\\begin{center}\n  #{includegraphics}\n\\\\end{center}")
  when /SHIFT/
    puts(includegraphics)
  else
    puts(include_figure(path))
  end
end

# =========================================
# = Insert Citation Based On Current Word =
# =========================================

# Return a list of citation strings for the current document.
#
# +input+ is used to filter the possible citations.
#
# = Arguments
#
# [input] A string used to filter the citations for the current document
#
# = Output
#
# A list of citation strings and a boolean, which states if we should overwrite
# the input or keep it.
#
# = Examples
#
#  doctest: Get the citation in 'references.tex' containing the word 'robertson'
#
#  >> ENV['TM_LATEX_MASTER'] = 'Tests/TeX/references.tex'
#  >> cites, replace_input = citations('robertson')
#  >> cites.length
#  => 1
#  >> replace_input
#  => true
#
#  doctest: Get all citations for the file 'references.tex'
#
#  >> ENV['TM_LATEX_MASTER'] = 'Tests/TeX/references.tex'
#  >> cites, replace_input = citations('}')
#  >> cites.length
#  => 5
#  >> replace_input
#  => false
def citations(input)
  items = LaTeX.citations.map(&:to_s)
  filter_items_replace_input(items, input)
end

# Insert a citation into a document based on the given input.
#
# = Arguments
#
# [input] A string used to filter the possible citations for the current
#         document
def insert_citation(input)
  menu_items, replace_input = citations(input)
  selection = menu_choice_exit_if_empty(menu_items).slice(/^[^\s]+/)
  output_selection(selection, input, replace_input)
rescue RuntimeError => e
  exit_show_tool_tip(e.message)
end

# ===================================
# = Insert Citation (Ref-TeX Style) =
# ===================================

# Display a menu that lets the user choose a certain cite environment.
#
# This function exits if none of the cite environments was chosen.
#
# = Output
#
# The function returns the chosen environment.
def choose_cite_environment
  items = ['u:  \\autocite',    'c:  \\cite',
           't:  \\citet',       '    \\citet*',
           'p:  \\citep',       '    \\citep*',
           'e:  \\citep[e.g.]', 's:  \\citep[see]',
           'a:  \\citeauthor',  '    \\citeauthor*',
           'y:  \\citeyear',    'r:  \\citeyearpar',
           'f:  \\footcite',    'x:  \\textcite']
  items = items.grep(/.*\\(?:#{ENV['TM_LATEX_REFTEX_FILTER']})$/) if
    ENV['TM_LATEX_REFTEX_FILTER']
  menu_choice_exit_if_empty(items).gsub(/.*\\/, '')
end

# Insert an “extended” citation into a document based on the given input.
#
# = Arguments
#
# [input] A string used to filter the possible citations for the current
#         document
def insert_reftex_citation(input)
  if ENV['TM_SCOPE'] =~ /citation/ then insert_citation(input)
  else
    cite_environment = choose_cite_environment
    citations, replace_input = citations(input)
    citation = menu_choice_exit_if_empty(citations).slice(/^[^\s]+/)
    exit_insert_snippet("#{replace_input ? '' : input}" \
      "\\#{cite_environment}${1:[$2]}\{#{citation}$3\}$0")
  end
rescue RuntimeError => e
  exit_insert_text(e.message)
end

# ======================================
# = Insert Label Based On Current Word =
# ======================================

# Insert a label into a document based on the given input.
#
# = Arguments
#
# [input] A string used to filter the possible labels for the current document
def insert_label(input)
  menu_items, replace_input = filter_items_replace_input(LaTeX.label_names,
                                                         input)
  selection = menu_choice_exit_if_empty(menu_items)
  output_selection(selection, input, replace_input, 'label')
rescue RuntimeError => e
  exit_show_tool_tip(e.message)
end

# =========================
# = Insert LaTeX Template =
# =========================

# Return the paths of the template directories.
#
# = Output
#
# This function returns a list containing the path to the template directory.
def template_directories
  [ENV['TM_BUNDLE_SUPPORT'] + '/templates',
   ENV['HOME'] + '/Library/Application Support/LaTeX/Templates/']
end

# Return the name and content of the files in the template directories.
#
# = Output
#
# A list of files, each represented by a dictionary containing the filename and
# the content of the file.
def template_entries
  template_directories.map do |directory|
    Dir.glob("#{directory}/*.tex").map do |file|
      { 'filename' => File.basename(file), 'content' => File.read(file) }
    end
  end.flatten
end

# Return the template text of the selected template.
#
# = Output
#
# A string containing the content of the chosen template.
def template_text
  command = "\"#{ENV['DIALOG']}\" -cmp " \
            "#{e_sh({ 'entries' => template_entries }.to_plist)} " \
            "#{e_sh(ENV['TM_BUNDLE_SUPPORT'] + '/nibs/Templates')}"
  result = OSX::PropertyList.load(`#{command}`)['result']
  exit_discard if result.nil?
  result['returnArgument'][0].scan(/\n|.+\n?/)
end

# Insert a template at the current position of the caret.
def insert_template
  text = template_text
  # The user can force the template to be interpreted as a snippet, by
  # adding the line: %!TEX style=snippet at the beginning of the template
  exit_insert_snippet(text[1..-1]) if
    text[0] =~ /^%\s*!TEX\s+style\s*=\s*snippet\s*/
  print(text.join(''))
end

# ======================
# = Open Included Item =
# ======================

# Get the location of an included item.
#
# = Arguments
#
# [input] The text that should be searched for an included item
#
# = Output
#
# The function returns a string that contains the location of an included item.
# If no location was found, then it returns an empty string
def locate_included_item(input)
  environment = '\\\\(?:include|input|includegraphics|lstinputlisting)'
  comment = '(?:%.*\n[ \t]*)?'
  option = '(?>\[.*?\])?'
  file = '(?>\{(.*?)\})'
  match = input.scan(/#{environment}#{comment}#{option}#{comment}#{file}/m)
  match.empty? ? '' : match.pop.pop.gsub(/(^\")?(\"$)?/, '')
end

# Get the currently selected text in TextMate
#
# If no text is selected, then content of the current line will be returned.
#
# = Output
#
# The function a string containing the current selection. If the selection is
# empty, then it returns the content current line.
def selection_or_line
  ENV['TM_SELECTED_TEXT'] || ENV['TM_CURRENT_LINE']
end

# Open the file located at +location+.
#
# = Arguments
#
# [location] The path to the file that should be opened.
def open_file(location)
  filepath = `kpsewhich #{e_sh location}`.chomp
  if filepath.empty?
    possible_files = Dir["#{location}*"]
    filepath = possible_files.pop unless possible_files.empty?
  end
  if filepath.empty?
    exit_show_tool_tip("Could not locate file for path “#{location}”")
  end
  `open #{e_sh filepath}`
end

# Open an included item in a tex file.
#
# For example: If the current line contains `\input{included_item}`, then this
# command will open the file with the filename +included_item+.
def open_included_item
  master = masterfile
  input = selection_or_line
  Dir.chdir(File.dirname(master)) unless master.nil?
  location = locate_included_item(input)
  if location.empty?
    exit_show_tool_tip('Did not find any appropriate item to open in ' \
                       "“#{input}”")
  end
  open_file(location)
end

# ====================
# = Open Master File =
# ====================

# Open the current master file in TextMate
def open_master_file
  master = masterfile
  if master == ENV['TM_FILEPATH']
    print('Already in master file')
  else
    `open -a TextMate #{e_sh master}`
  end
rescue RuntimeError => e
  exit_show_tool_tip(e.message)
end

# ==========================
# = Show Label As Tool Tip =
# ==========================

# Get the text surrounding a certain label.
#
# = Arguments
#
# [label] The label for which we want to get the surrounding text
#
# = Output
#
# This function returns a string containing the text around the given label.
def label_context(label)
  # Try to get as much context as possible
  [10, 5, 2, 1, 0].each do |lines|
    context = label.context(lines)
    return context unless context.nil?
  end
end

# Print the text surrounding a label referenced in the string +input+.
#
# = Arguments
#
# [input] A string that is checked for references
def show_label_as_tooltip(input)
  if input.empty?
    exit_show_tool_tip('Empty input! Please select a (partial) label' \
                       ' reference.')
  end
  labels = LaTeX.labels.find_all { |label| label.label.match(/#{input}/) }
  exit_show_tool_tip("No label found matching “#{input}”") if labels.empty?
  print(label_context(labels[0]))
rescue RuntimeError => e
  exit_insert_text(e.message)
end
