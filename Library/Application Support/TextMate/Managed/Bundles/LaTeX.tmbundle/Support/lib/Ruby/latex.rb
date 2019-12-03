require 'strscan'
require 'pathname'
require 'shellwords'

# The LaTeX module contains a lot of methods useful when dealing with LaTeX
# files.
#
# Authors:: Charilaos Skiadas, René Schwaiger
#
# rubocop: disable Lint/MissingCopEnableDirective
# rubocop: disable Metrics/ModuleLength
module LaTeX
  # Parse any %!TEX options in the first 20 lines of the file.
  #
  # We use the first 20 lines for compatibility with TeXShop.
  #
  # = Arguments
  #
  # [filepath] The path of the file that should be parsed.
  #
  # = Output
  #
  # This function returns a hash containing the tex directives contained in the
  # given file.
  #
  # = Examples
  #
  #  doctest: Parse the tex directives in 'xelatex.tex'
  #
  #  >> LaTeX.options('Tests/TeX/xelatex.tex')
  #  => {"program"=>"xelatex", "spellcheck"=>"en-US",
  #      "encoding"=>"UTF-8 Unicode"}
  #
  #  doctest: Parse the tex directives in 'packages_input1.tex'
  #
  #  >> LaTeX.options('Tests/TeX/input/packages_input1.tex')
  #  => {"root"=>"./packages_input2.tex"}
  def self.options(filepath)
    opts = {}
    File.foreach(filepath).first(20).each do |line|
      opts[Regexp.last_match[1]] = Regexp.last_match[2] if
        line =~ /^\s*%\s*!T[eE]X\s*(\S+)\s*=\s*(.+)\s*$/
    end
    opts
  end

  # Returns the root/master file for the given filepath.
  #
  # If no master exists, then this function returns the given filepath. We stop
  # searching after 10 iterations, in case of a loop.
  #
  # = Arguments
  #
  # [filepath] The path of the file for which we want to determine the master
  #
  # = Output
  #
  # The function returns the path of the master file
  #
  # = Examples
  #
  #  doctest: Determine the master document of the file 'packages_input1.tex'
  #
  #  >> LaTeX.master('Tests/TeX/input/packages_input1.tex')
  #  => 'Tests/TeX/packages.tex'
  #
  #  doctest: Determine the master document of the file 'xelatex.tex'
  #
  #  >> LaTeX.master('Tests/TeX/xelatex.tex')
  #  => 'Tests/TeX/xelatex.tex'
  def self.master(filepath)
    return nil if filepath.nil?

    master = Pathname.new(filepath).cleanpath
    master = master_from_tex_directives(master)
    raise 'There is a loop in your %!TEX root directives.' unless master

    master
  end

  # Get the master file following +%!TEX root+ directives.
  #
  # = Arguments
  #
  # [master] The filepath of the master file.
  #
  # = Output
  #
  # The function returns the path to the new master file. If one of the files
  # specified via +%!TEX root+ could not be found, then an error will be raised.
  #
  # = Examples
  #
  #  doctest: Determine the master document of the file 'packages_input2.tex'
  #
  #  >> master = Pathname.new('Tests/TeX/input/packages_input2.tex')
  #  >> LaTeX.master_from_tex_directives(master)
  #  => 'Tests/TeX/packages.tex'
  #
  #  doctest: Try to get a nonexistent master file
  #
  #  >> begin
  #       master = Pathname.new('Tests/TeX/wrong master path.tex')
  #       LaTeX.master_from_tex_directives(master)
  #       rescue Exception => e
  #       e.message =~ /Master file .+does not exist\.tex does not exist!/
  #       end
  #  => 0
  def self.master_from_tex_directives(master)
    10.times do
      raise "Master file #{master} does not exist!" unless master.exist?

      root = options(master)['root']
      return master.to_s unless root

      new_master = (master.parent + Pathname.new(root)).cleanpath
      return master.to_s if new_master == master

      master = new_master
    end
  end

  # Implements general methods that give information about the LaTeX document.
  # Most of these commands recurse into \included files.
  class <<self
    # Get the list of commands contained in the current master file.
    #
    # = Output
    #
    # The function returns a list of strings. Each string represents a command.
    #
    # = Examples
    #
    #  doctest: Check the commands of the file 'packages_input1.tex'.
    #
    #  >> ENV['TM_FILEPATH'] = 'Tests/TeX/input/packages_input1.tex'
    #  >> LaTeX.commands.include? 'setmainlanguage'
    #  => true
    def commands
      FileScanner.command_scan(LaTeX.master(ENV['TM_LATEX_MASTER'] ||
                                            ENV['TM_FILEPATH']))
    end

    # Get an array containing the labels of the current master file.
    #
    # = Output
    #
    # The function returns a list of label objects.
    #
    # = Examples
    #
    #  doctest: Get the number of labels contained in 'references.tex'.
    #
    #  >> ENV['TM_LATEX_MASTER'] = 'Tests/TeX/references.tex'
    #  >> LaTeX.labels.length
    #  => 4
    def labels
      master_file = LaTeX.master(ENV['TM_LATEX_MASTER'] || ENV['TM_FILEPATH'])
      FileScanner.label_scan(master_file)
    end

    # Get an array containing the label names of the current master file.
    #
    # = Output
    #
    # The function returns a sorted list of label names.
    #
    # = Examples
    #
    #  doctest: Get the labels of the file 'references.tex'.
    #
    #  >> ENV['TM_FILEPATH'] = 'Tests/TeX/references.tex'
    #  >> LaTeX.label_names
    #  => ["sec:first_section", "sec:included_section",
    #      "sec:second_section", "table:a_table_label"]
    #
    #  doctest: Get the labels of the file 'xelatex.tex'.
    #
    #  >> ENV['TM_LATEX_MASTER'] = 'Tests/TeX/xelatex.tex'
    #  >> LaTeX.label_names
    #  => []
    def label_names
      labels.map(&:label).sort
    end

    # Return an array of citation objects for the current tex file.
    #
    # If you only want the citekeys, then use +LaTeX.citekeys+.
    #
    # The path to the master file has to be set via the environment variable
    # +TM_LATEX_MASTER+ or +TM_FILEPATH+.
    #
    # = Output
    #
    # The function returns a list of citations hashes.
    #
    #  doctest: Get the citations of the file 'external_bibliography.tex'.
    #
    #  >> ENV.delete 'TM_LATEX_MASTER'
    #  >> ENV['TM_FILEPATH'] = 'Tests/TeX/external_bibliography.tex'
    #  >> citations = LaTeX.citations
    #  >> citations.length
    #  => 1
    #  >> first_cite = citations[0]
    #  >> first_cite['citekey']
    #  => 'Deltron3030'
    #
    #  doctest: Get the citations of the file 'external_bibliography_biber.tex'.
    #
    #  >> ENV['TM_FILEPATH'] = 'Tests/TeX/external_bibliography_biber.tex'
    #  >> citations = LaTeX.citations
    #  >> citations.length
    #  => 1
    #  >> first_cite = citations[0]
    #  >> first_cite['title']
    #  => 'Battlesong'
    #
    #  doctest: Get the citations of the file 'references.tex'.
    #
    #  >> ENV['TM_FILEPATH'] = 'Tests/TeX/references.tex'
    #  >> LaTeX.citations.length
    #  => 5
    #
    #  doctest: Retrieve the citations of the file 'missing_cite_key.tex'.
    #
    #  >> ENV['TM_FILEPATH'] = 'Tests/TeX/missing_cite_key.tex'
    #  >> LaTeX.citations.length
    #  => 1
    def citations
      master_file = LaTeX.master(ENV['TM_LATEX_MASTER'] || ENV['TM_FILEPATH'])
      # We filter citations without cite key. While BibDesk will not allow you
      # to save such broken citations, JabRef allows you to save entries without
      # a key.
      valid_citations = FileScanner.cite_scan(master_file).reject do |citation|
        citation.citekey.nil?
      end
      valid_citations.sort_by(&:citekey)
    end

    # Returns an array of the citekeys for the current master file.
    #
    # The path to the master file has to be set via the environment variable
    # +TM_LATEX_MASTER+ or +TM_FILEPATH+.
    #
    # = Output
    #
    # The function returns a list of all citekeys.
    #
    #  doctest: Get the citation keys of the file 'references.tex'.
    #
    #  >> ENV['TM_FILEPATH'] = 'Tests/TeX/references.tex'
    #  >> keys = LaTeX.citekeys
    #  >> keys.length
    #  => 5
    #  >> keys.member? 'embedded_bibitem'
    #  => true
    def citekeys
      citations.map(&:citekey).uniq
    end

    # Return the path to the TeX binaries.
    #
    # If the location is part of the environment variable +PATH+, then this
    # function returns the empty string. If +tex_path+ can not find the
    # location of the tex binaries, then it raises an error.
    #
    # = Output
    #
    # The function returns the prefix needed to execute tex programs.
    #
    # doctest: Get the path of the tex binaries.
    #
    #  >> ['/Library/TeX/texbin/', ''].include? LaTeX.tex_path
    #  => true
    def tex_path
      # First try directly
      return '' if ENV['PATH'].split(':').find do |dir|
        File.exist? File.join(dir, 'kpsewhich')
      end

      # Then try some specific paths
      ['/Library/TeX/texbin/', '/usr/texbin/', '/opt/local/bin/'].each do |dir|
        return dir if File.exist?("#{dir}kpsewhich")
      end
      # If all else fails, rely on /etc/profile. For most people, we should
      # never make it here.
      loc = `. /etc/profile; which kpsewhich`.rstrip
      return loc.gsub(/kpsewhich$/, '') unless loc =~ /^no kpsewhich/

      raise 'The tex binaries cannot be located!'
    end

    # Get the path of a certain file.
    #
    # = Arguments
    #
    # [filepath] This argument specifies the path of the file this function
    #            should locate. If this path is not absolute, then it is
    #            relative to the path specified via the argument +directory+.
    #
    # [extension] This variable contains the (optional) extension of the file
    #             this function locates.
    #
    # [directory] The variable +directory+ should be included in the paths to
    #             look at, when searching for the file specified via the
    #             argument +filepath+. Typically this variable will contain the
    #             directory of the master file.
    #
    # = Output
    #
    # The function returns the filepath of the specified file or +nil+ if the
    # file could not be found.
    #
    # = Examples
    #
    #  doctest: Get the location of the file “packages_input1.tex”
    #
    #  >> filepath = LaTeX.find_file('input/packages_input1', 'tex',
    #                                'Tests/TeX/')
    #  >> filepath.end_with?('Tests/TeX/input/packages_input1.tex')
    #  => true
    #
    #  doctest: Get the location of the file “xelatex.tex”
    #
    #  >> filepath = LaTeX.find_file('"xelatex.tex"', 'tex', 'Tests/TeX/')
    #  >> filepath.end_with?('Tests/TeX/xelatex.tex')
    #  => true
    #
    #  doctest: Get the location of a file located in the TeX tree
    #
    #  >> filepath = LaTeX.find_file('config/pdftexconfig', 'tex', '')
    #  >> filepath.end_with?('config/pdftexconfig.tex')
    #  => true
    #
    #  doctest: Try to get the location of a non-existent file
    #
    #  >> LaTeX.find_file('la', 'tex', '')
    #  => nil
    #
    #  doctest: Get the location of a file located deep within the TeX tree
    #
    #  >> filepath = LaTeX.find_file('article.cls', 'cls', '')
    #  >> filepath.end_with?('latex/base/article.cls')
    #  => true
    #
    #  doctest: Get the location of a file specified via an absolute path
    #
    #  >> absolute_path =
    #     '/Library/TeX/Root/texmf-dist/tex/latex/base/article.cls'
    #  >> LaTeX.find_file(absolute_path, 'cls', '')
    #  => absolute_path
    #
    #  doctest: Locate bibliography file located in TeX tree
    #
    #  >> LaTeX.find_file('xampl', 'bib', '').end_with?('bib/base/xampl.bib')
    #  => true
    def find_file(filepath, extension, directory)
      filepath = filepath.delete('"').sub(/\.#{extension}$/, '') + \
                 ".#{extension}"
      paths = [filepath, File.join(directory, filepath)]
      paths.each { |path| return path if file?(path) }
      find_file_kpsewhich(filepath)
    end

    # Processes a bib file and return an array of citation objects.
    #
    # = Arguments
    #
    # [filepath] The path to the bib file that should be parsed
    #
    # = Output
    #
    # The function returns a list of citation objects.
    #
    # = Examples
    #
    #  doctest: Parse the file 'references.bib'
    #
    #  >> references = LaTeX.parse_bibfile('Tests/TeX/references.bib')
    #  >> references.length
    #  => 1
    #  >> citation = references[0]
    #  >> citation.author
    #  => 'Deltron 3030'
    #  >> citation.title
    #  => 'Battlesong'
    #
    #  doctest: Parse the file 'more_references.bib'
    #
    #  >> references = LaTeX.parse_bibfile('Tests/TeX/more_references.bib')
    #  >> references.length
    #  => 3
    #  >> citation = references[0]
    #  >> citation.author
    #  => 'Robertson, Venetia Laura Delano'
    #  >> citation.citekey
    #  => 'robertson2013ponies'
    #
    #  >> citation = references[2]
    #  >> citation.author
    #  => 'Hada, Erika'
    #  >> citation.title
    #  => 'My Little Pony'
    def parse_bibfile(filepath)
      entries = bib_entries(filepath)
      bib_citations(entries, bib_variables(entries))
    end

    # Parse a bib file and return a list of its entries.
    #
    # = Arguments
    #
    # [filepath] The path to the bib file that should be parsed
    #
    # = Output
    #
    # The function returns a list of entry strings.
    #
    # = Examples
    #
    #  doctest: Get the bib entries of the file 'references.bib'
    #
    #  >> references = LaTeX.bib_entries('Tests/TeX/more_references.bib')
    #  >> references.all? { |entry| !(entry =~ /^@[^{]+\{.*\}\Z/m).nil? }
    #  => true
    #
    #  doctest: Get the bib entries of the 'unformatted.bib'
    #
    #  >> references = LaTeX.bib_entries('Tests/TeX/unformatted.bib')
    #  >> references[1]
    #  => "@article{A, author = {A}}"
    def bib_entries(filepath)
      raise "Could not locate file: #{filepath}" unless file?(filepath)

      entries = File.read(filepath).scan(/^\s*@[^\{]*\{.*?(?=\n[ \t]*@|\z)/m)
      entries.map { |entry| entry.strip.gsub(/(?:^\s*%.*|\n)+$/m, '') }
    end

    # Extract variables from a list of bib entries.
    #
    # A bib entry that contains a variable has the syntax
    #
    #  @string { name = value }
    #
    # For example, the following code defines a variable named +favorite_pony+
    # containing the value +Fluttershy+.
    #
    #  @string { favorite_pony = "Fluttershy" }
    #
    # This function returns all variables saved in the given bib entries as
    # hash. The hash uses variable names as keys and the content of a variable
    # as values.
    #
    # = Arguments
    #
    # [bib_entries] A list of bib entries saved as string.
    #
    # = Output
    #
    # The function returns a hash containing variables and their values.
    #
    # = Examples
    #
    #  doctest: Parse some simple variable definitions
    #
    #  >> entries = ['@string { show = "Gravity Falls" }',
    #                '@string { characters =
    #                           "Dipper, Mabel, Stan, Soos, Wendy, Waddles" }',
    #                '@misc { key, author = {Author}}']
    #  >> variables = LaTeX.bib_variables(entries)
    #  >> variables['show']
    #  => 'Gravity Falls'
    #  >> variables['characters']
    #  => 'Dipper, Mabel, Stan, Soos, Wendy, Waddles'
    #
    #  doctest: Parse the variable definitions in the file 'unformatted.bib'
    #
    #  >> vars = LaTeX.bib_variables(
    #       LaTeX.bib_entries('Tests/TeX/unformatted.bib'))
    #  >> vars['pink_pony']
    #  => 'Pinkie Pie'
    #  >> vars['white_pony']
    #  => 'Deftones'
    def bib_variables(bib_entries)
      variables = bib_entries.select { |entry| entry.start_with? '@string' }
      variables.map! do |entry|
        entry.gsub(/@string\s*\{\s*/m, '').gsub(/\s*\}$/m, '')
      end
      vars = {}
      variables.each do |var_value|
        key, value = var_value.split(/\s*=\s*(?:\{|")/)
        vars[key] = value[0..-2] unless value.nil?
      end
      vars
    end

    # Extract citations from a list of bib entries.
    #
    # = Arguments
    #
    # [bib_entries] A list containing bib entries
    # [bib_variables] A hash containing bib variables and their values
    #
    # = Output
    #
    # This function returns a list of citation objects.
    #
    # = Examples
    #
    #  doctest: Parse some simple bib entries
    #
    #  >> entries = ['@misc{key, author = "Author, Mrs.", title = "Title"}',
    #                '@article{Key, TiTLe = "Masters Of War",
    #                               Author = "Dylan, Bob"}']
    #  >> cites = LaTeX.bib_citations(entries, {})
    #  >> cites[0]['author']
    #  => 'Author, Mrs.'
    #  >> cites[1]['author']
    #  => 'Dylan, Bob'
    #  >> cites[1]['title']
    #  => 'Masters Of War'
    #
    #  doctest: Parse bib entries containing comments and variables
    #
    #  >> variables = { 'start' => "Tesla, you don't understand",
    #                   'end' => ' humor.' }
    #  >> entries = ['@COMMENT{ This is a comment}',
    #                '@electronic{tesla, author = "Tesla, Nikola",
    #                             year="1856",
    #                             title= start # " our " # {American} # end }']
    #  >> cites = LaTeX.bib_citations(entries, variables)
    #  >> cites[0]['title']
    #  >> "Tesla, you don't understand our American humor."
    def bib_citations(bib_entries, bib_variables)
      citations = bib_entries.select do |entry|
        (entry =~ /@(?:string|preamble|comment)/i).nil?
      end
      cites = citations.map do |citation|
        bib_citation(citation, bib_variables)
      end
      cites.compact
    end

    # Convert one citation bib entry to a +Citation+.
    #
    # = Arguments
    #
    # [bib_entry] The bib entry, which should be converted to a +Citation+
    # [bib_variables] A dictionary containing all bib variables and their values
    #
    # = Output
    #
    # The function returns a Citation object on success or +nil+ if it failed.
    #
    # = Examples
    #
    #  doctest: Parse a simple bib entry
    #
    #  >> entry = '@article{key,
    #                       author = "Mabel",
    #                       title = "On why pet pigs are " # synonym_nice}'
    #  >> variables = { 'synonym_nice' => 'awesome' }
    #  >> cite = LaTeX.bib_citation(entry, variables)
    #  >> cite['title']
    #  => "On why pet pigs are awesome"
    #
    #  doctest: Parse a complex bib entry
    #
    #  >> entry = '@article{IEEE_1003_5,
    #     Date-Modified = {2010-09-01 14:52:36 +0200},
    #     Journal = {IEEE Std 1003.5, 1999 Edition},
    #     Keywords = {UnixAda language bindings, IEEE standard, ISO 8652,
    #     ISO IEC, 9945-1, POSIX, application portability},
    #     Pages = {1-890},
    #     Title = {I{EEE Standard for Information Technology - POSIX(R) Ada
    #     Language Interfaces - Part 1: Binding for System Application Program
    #     Interface (API) - Amendment 2: Protocol-Independent Interfaces}},
    #     Year = 1999,
    #     Bdsk-Url-1 = {http://dx.doi.org/10.1109/IEEESTD.1999.90614}}'
    #  >> cite = LaTeX.bib_citation(entry, {})
    #  >> cite['bdsk-url-1']
    #  => 'http://dx.doi.org/10.1109/IEEESTD.1999.90614'
    #  >> cite['title'].end_with?('Protocol-Independent Interfaces}')
    #  => true
    def bib_citation(bib_entry, bib_variables)
      bibtype, citekey, rest = bibentry_type_key_rest(bib_entry)
      return nil if bibtype.nil?

      cite = Citation.new('bibtype' => bibtype, 'citekey' => citekey)
      rest[0..-2].split(/("|\}|\d)\s*,/).each_slice(2).map(&:join).
        map(&:strip).each do |key_value|
        key, value = bibitem_key_value(key_value, bib_variables)
        cite[key] = value unless key.nil?
      end
      cite
    end

    # Extract the bib type and citekey from a bib entry.
    #
    # = Arguments
    #
    # [bib_entries] A list containing bib entries.
    # [bib_variables] A hash containing bib variables and their values
    #
    # = Output
    #
    # The function returns a list containing the type, citekey and the remaining
    # part of a bib entry.
    #
    # = Examples
    #
    #  doctest: Get the type and key of a simple bib entry
    #
    #  >> entry = '@misc{key, author = "Author, Mrs.", title = "Title"}'
    #  >> LaTeX.bibentry_type_key_rest(entry)
    #  => ['misc', 'key', 'author = "Author, Mrs.", title = "Title"}']
    def bibentry_type_key_rest(bib_entry)
      scanner = StringScanner.new(bib_entry)
      scanner.scan(/\s*@/)
      bibtype = scanner.scan(/[^\s\{]+/)
      scanner.scan(/\s*\{\s*/)
      citekey = scanner.scan(/[^\s,]+(?=\s*,)/)
      scanner.scan(/\s*,\s*/)
      [bibtype, citekey, scanner.rest]
    end

    # Extract the key and value of a single item of a bib entry.
    #
    # = Arguments
    #
    # [bib_item] A string containing a single bib item and its value
    # [bib_variables] A hash containing bib variables and their values
    #
    # = Output
    #
    # The function returns the key and value of the bib item or +nil+ if the
    # key or value could not be extracted.
    #
    # = Examples
    #
    #  doctest: Get the key and value of a simple bib item
    #
    #  >> bib_item = 'editor = "TextMate"'
    #  >> key, value = LaTeX.bibitem_key_value(bib_item, {})
    #  >> key
    #  => 'editor'
    #  >> value
    #  => 'TextMate'
    #
    #  doctest: Get the key and value of a bib item containing a variable
    #
    #  >> bib_item = 'hulk = "Smash" # exclamation'
    #  >> key, value = LaTeX.bibitem_key_value(bib_item,
    #                                          { 'exclamation' => '!' })
    #  >> key
    #  => 'hulk'
    #  >> value
    #  => 'Smash!'
    #
    #  doctest: Get the key and value of a bib item containing a number sign
    #
    #  >> variables = { 'number_sign' => '#' }
    #  >> bib_item = 'item = "# number"# number_sign # {oh a {#} {sign}#}'
    #  >> _, item = LaTeX.bibitem_key_value(bib_item, variables)
    #  >> item
    #  => '# number#oh a {#} {sign}#'
    #
    #  doctest: Get the key and value of a bib item containing a number
    #
    #  >> bib_item = 'iTeM = 1984'
    #  >> _, item = LaTeX.bibitem_key_value(bib_item, variables)
    #  >> item
    #  => '1984'
    #
    #  doctest: Get the key and value of a bib item that contains '}}'
    #
    #  >> _, value = LaTeX.bibitem_key_value('Title = {{"Hi"}}', {})
    #  >> value
    #  => '{"Hi"}'
    def bibitem_key_value(bib_item, bib_variables)
      key, value = bib_item.split(/\s*=\s*(?=\{|"|\w)/)
      return nil if value.nil?

      [key.downcase, bib_item_value(value, bib_variables)]
    end

    private

    def bib_item_value(string, bib_variables)
      scanner = StringScanner.new(string)
      value = ''
      until scanner.empty?
        part = get_part(scanner, bib_variables)
        scanner.scan(/\s*#\s*/m)
        value += part unless part.nil?
      end
      value
    end

    def get_part(scanner, bib_variables)
      first = scanner.getch
      if first == '"' then consume_value_quotes(scanner)
      elsif first == '{' then consume_value_brackets(scanner)
      elsif first =~ /\d/ then first + scanner.scan(/\d*/)
      else consume_value_variable(scanner, first, bib_variables)
      end
    end

    def consume_value_quotes(scanner)
      scanned = scanner.scan(/(?:[^"]|\\")+"/)
      scanned.nil? ? nil : scanned[0..-2]
    end

    def consume_value_brackets(scanner)
      missing_right_brackets = 1
      value = ''
      while missing_right_brackets > 0
        scanned = scanner.scan(/(?:[^{}]|\\[{}])+/)
        value += scanned.to_s
        bracket = scanner.getch
        missing_right_brackets += bracket == '{' ? 1 : -1
        value += bracket.to_s unless missing_right_brackets <= 0
      end
      value
    end

    def consume_value_variable(scanner, first_char, variables)
      scanned = scanner.scan(/[\w]*/)
      scanned.nil? ? nil : variables[first_char + scanned].to_s
    end

    def file?(filepath)
      !filepath.nil? && File.exist?(filepath) && !File.directory?(filepath)
    end

    def find_file_kpsewhich(filename)
      path = `#{LaTeX.tex_path}kpsewhich #{filename.shellescape}`.rstrip
      file?(path) ? path : nil
    end
  end

  # A class implementing a recursive scanner.
  #
  # = Accessors
  #
  # [root] The file where the scanning process starts
  #
  # [includes] A hash with regular expressions as keys and blocks of code as
  #            values. The blocks are executed when the regex matches. The
  #            block is passed the match as argument. It must must return the
  #            full path to the file to be recursively scanned.
  #
  # [extractors] A hash similar to +includes+. It deals with the bits of text to
  #              be matched. The block has the following arguments:
  #              - the current filename,
  #              - the current line number,
  #              - the regex match and
  #              - the content of the file.
  #
  # rubocop: disable Metrics/ClassLength
  class FileScanner
    attr_accessor :root, :includes, :extractors

    # Create a new scanner object.
    #
    # If the argument +old_scanner+ is a string, then it is set as the +root+
    # file. Otherwise the new scanner just copies the accessor values from the
    # given scanner.
    #
    # = Arguments
    #
    # [scanner] The scanner which should be used as template for the new scanner
    #           or a string, which specifies the +root+ for the new scanner.
    def initialize(scanner = nil)
      if scanner.nil?
        set_defaults
      elsif scanner.is_a?(String)
        @root = scanner
        set_defaults
      else
        @root = scanner.root
        @includes = scanner.includes
        @extractors = scanner.extractors
      end
    end

    # Set default values for the +includes+ and +extractors+ hash.
    def set_defaults
      @includes = {}
      # We ignore inputs and includes containing a hash since these are
      # usually used as arguments inside macros e.g. `#1` to access the first
      # argument of a macro
      @includes[/^[^%]*(?:\\include|\\input)\s*\{([^}\\#]*)\}/] = proc do |m|
        m[0].split(',').map do |it|
          LaTeX.find_file(it.strip, 'tex', File.dirname(@root)) ||
            raise("Could not locate any file named '#{it}'")
        end
      end
      @extractors = {}
    end

    # Perform the recursive scanning.
    def recursive_scan
      raise 'No root specified!' if @root.nil?
      raise "Could not find file #{@root}" unless File.exist?(@root)

      text = File.read(@root)
      text.lines.each_with_index do |line, line_number|
        includes.each_pair do |regex, block|
          include_process_line(line, regex, block)
          extractors_process_line(root, line, line_number, extractors, text)
        end
      end
    end

    # Get the commands of the file +root+ and all its included files.
    #
    # = Arguments
    #
    # [root] The file which should be searched for commands
    #
    # = Output
    #
    # The function returns a list of strings. Each string represents a LaTeX
    # command.
    #
    # = Examples
    #
    #  doctest: Scan the file +makeindex.tex+ for commands
    #
    #  >> include LaTeX
    #  >> commands = FileScanner.command_scan('Tests/TeX/makeindex.tex')
    #  >> commands.include? 'makeindex'
    #  >> commands.length
    #  => 9
    def self.command_scan(root)
      commands = []
      scanner = FileScanner.new(root)
      scanner.extractors[/\\([\w@]+)/] = proc do |_, _, groups, _|
        commands << groups[0]
      end
      scanner.recursive_scan
      commands.uniq
    end

    # Get the labels of the file +root+ and all its included files.
    #
    # = Arguments
    #
    # [root] The file which should be searched for labels
    #
    # = Output
    #
    # The function returns a list of label objects.
    #
    # = Examples
    #
    #  doctest: Scan the file +xelatex.tex+ for labels
    #
    #  >> include LaTeX
    #  >> FileScanner.label_scan('Tests/TeX/xelatex.tex')
    #  => []
    #
    #  doctest: Scan the file +references.tex+ for labels
    #
    #  >> include LaTeX
    #  >> labels = FileScanner.label_scan('Tests/TeX/references.tex')
    #  >> labels.map(&:file).uniq.length
    #  => 2
    def self.label_scan(root)
      label_list = []
      scanner = FileScanner.new(root)
      label_extractor = proc do |filename, line, groups, text|
        label_list << Label.new(:file => filename, :line => line,
                                :label => groups[0], :contents => text)
      end
      scanner.extractors[/.*?\[.*label=(.*?)\,.*\]/] = label_extractor
      scanner.extractors[/^[^%]*\\label\{([^\}]*)\}/] = label_extractor
      scanner.recursive_scan
      label_list
    end

    # Get the citations of the file +root+ and all its included files.
    #
    # = Arguments
    #
    # [root] The file which should be searched for citations
    #
    # = Output
    #
    # The function returns a list of citations objects.
    #
    # = Examples
    #
    #  doctest: Scan the file +packages.tex+ for citations
    #
    #  >> include LaTeX
    #  >> FileScanner.cite_scan('Tests/TeX/packages.tex')
    #  => []
    #
    #  doctest: Scan the file +references.tex+ for citations
    #
    #  >> include LaTeX
    #  >> cites = FileScanner.cite_scan('Tests/TeX/references.tex')
    #  >> cites.map(&:author).uniq.length
    #  => 5
    def self.cite_scan(root)
      scanner = FileScanner.new(root)
      class << scanner
        attr_accessor :cites
      end
      scanner.cites = []
      add_bibitem_scan(scanner)
      add_bibliography_scan(scanner)
      scanner.recursive_scan
      scanner.cites
    end

    class << self
      private

      def add_bibitem_scan(scanner)
        bibitem_regexp = /^[^%]*\\bibitem(?:\[[^\]]*\])?\{([^\}]*)\}(.*)/
        scanner.extractors[bibitem_regexp] = proc do |_, _, groups, _|
          scanner.cites << Citation.new('citekey' => groups[0],
                                        'cite_data' => groups[1])
        end
      end

      # rubocop: disable Metrics/AbcSize
      def add_bibliography_scan(scanner)
        # We ignore bibliography files located on Windows drives by not
        # +matching+ any path which starts with a single letter followed by a
        # “:” e.g.: “c:”
        regexes = [/^[^%]*\\bibliography\s*\{(?![a-zA-Z]:)([^\}]*)\}/,
                   /^[^%]*\\addbibresource\s*\{(?![a-zA-Z]:)([^\}]*)\}/]
        extractor = proc do |_, _, groups, _|
          (groups[0].split(',') << ENV['TM_LATEX_BIB']).compact.each do |bib|
            file = LaTeX.find_file(bib.strip, 'bib', File.dirname(scanner.root))
            raise "Could not locate any file named '#{bib}'" if file.nil?

            scanner.cites += LaTeX.parse_bibfile(file)
          end
        end
        scanner.extractors.update(Hash[regexes.map { |reg| [reg, extractor] }])
      end
    end

    private

    def include_process_line(line, regex, block)
      line.scan(regex).each do |match|
        newfiles = block.call(match)
        newfiles.each do |newfile|
          scanner = FileScanner.new(self)
          scanner.root = newfile.to_s
          scanner.recursive_scan
        end
      end
    end

    def extractors_process_line(root, line, line_number, extractors, text)
      extractors.each_pair do |extractor_regex, extractor_block|
        line.scan(extractor_regex).each do |match|
          extractor_block.call(root, line_number, match, text)
        end
      end
    end
  end

  # A class that represents a label.
  #
  # = Accessors
  #
  # [file] The file where the label is located
  # [line] The line where the label is located
  # [label] The text of the label
  # [contents] The whole content of the file around the label
  class Label
    attr_accessor :file, :line, :label, :contents

    # Initialize a new label
    #
    # = Arguments
    #
    # [hash] A hash containing initialization values for the accessors of the
    #        label.
    #
    # = Examples
    #
    #  doctest: Create a simple label
    #
    #  >> label = Label.new(:file => 'test.tex', :line => 1, :label => 'label',
    #                       :contents => 'Text around \label{label}.')
    def initialize(hash)
      hash.each { |key, value| send("#{key}=", value) }
    end

    # Return the string representation of a label.
    #
    # = Output
    #
    # A string representing the current label
    #
    # = Examples
    #
    # doctest: Get the string representation of a simple label
    #
    #  >> Label.new(:label => 'label_text').to_s
    #  => 'label_text'
    def to_s
      label
    end

    # Return the text around the label.
    #
    # = Arguments
    #
    # [lines] A number that specifies how many lines of text surrounding the
    #         label should be returned.
    #
    # = Output
    #
    # The function returns a match containing the text around the label.
    #
    # = Examples
    #
    #  doctest: Get the text around a label
    #
    #  >> label = Label.new(:contents => '
    #   ---
    #   \section{Second Section} % (fold)
    #     \label{sec:second_section}
    #   % section second_section (end)
    #   ---', :label => 'sec:second_section')
    #  >> context = label.context(2).to_s
    #  >> context.start_with?('\section{Second Section}')
    #  => true
    #  >> context.end_with?("% section second_section (end)\n")
    #  => true
    def context(lines = 10)
      half = lines / 2
      contents.match(/(.*\n){#{half}}.*\\label\{#{label}\}.*\n(.*\n){#{half}}/)
    end
  end

  # A class that represents a citation.
  #
  # The class provides a hash like interface to access the different attributes
  # of a citation.
  class Citation
    # Create a new citation.
    #
    # = Arguments
    #
    # [hash] A hash containing the attributes that should be used to initialize
    #        the citation.
    #
    # = Examples
    #
    #  doctest: Create a simple citation
    #
    #  >> Citation.new('author' => 'Some author', 'title' => 'A title' )
    def initialize(hash = {})
      @hash = {}
      hash.each_pair do |key, value|
        @hash[key.downcase] = value
      end
    end

    # Set an attribute of the citation.
    #
    # = Arguments
    #
    # [key] The name of the attribute
    # [value] The value of the attribute
    #
    # = Examples
    #
    #  doctest: Add an attribute to a citation
    #
    #  >> citation = Citation.new
    #  >> citation['author'] = 'Mabel'
    def []=(key, value)
      @hash[key.downcase] = value
    end

    # Get an attribute of the citation
    #
    # = Arguments
    #
    # [key] The name of the attribute for which the value should be returned.
    #
    # = Examples
    #
    #  doctest: Get the attribute of a citation
    #
    #  >> citation = Citation.new('title' => 'Title Fight')
    #  >> citation['title']
    #  => 'Title Fight'
    def [](key)
      @hash[key.downcase]
    end

    # Return the author of the citation
    #
    # = Examples
    #
    #  doctest: Get the author of a citation
    #
    #  >> Citation.new('author' => 'Defeater').author
    #  => 'Defeater'
    def author
      @hash['author'] || @hash['editor']
    end

    # Return the title of the citation
    #
    # = Examples
    #
    #  doctest: Get the title of a citation
    #
    #  >> Citation.new('title' => 'Empty Days & Sleepless Nights').title
    #  => 'Empty Days & Sleepless Nights'
    def title
      @hash['title']
    end

    # Return the description of the citation
    #
    # = Examples
    #
    #  doctest: Get the description of a citation
    #
    #  >> Citation.new('author' => 'Defeater',
    #                  'title' => 'Empty Days & Sleepless Nights').description
    #  => '✒️ Defeater 📕 Empty Days & Sleepless Nights'
    #  >> Citation.new('cite_data' => 'Description').description
    #  => 'Description'
    def description
      @hash['cite_data'] ||
        "#{author ? "✒️ #{author} " : ''}#{title ? "📕 #{title}" : ''}"
    end

    # Return the key of the citation
    #
    # = Examples
    #
    #  doctest: Get the key of a citation
    #
    #  >> Citation.new('citekey' => 'key_citation').citekey
    #  => 'key_citation'
    def citekey
      @hash['citekey']
    end

    # Return the string representation of a citation.
    #
    # = Output
    #
    # A string representing the current citation
    #
    # = Examples
    #
    # doctest: Get the string representation of a simple citation
    #
    #  >> Citation.new('citekey' => 'key', 'author' => 'Author',
    #                  'title' => 'The Title').to_s
    #  => 'key ✒️ Author 📕 The Title'
    def to_s
      citekey + (description.empty? ? '' : " #{description}")
    end
  end
end
