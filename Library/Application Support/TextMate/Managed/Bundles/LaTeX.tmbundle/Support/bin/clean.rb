#!/usr/bin/ruby

# Fix environment variable for command “Run DocTest”
ENV['TM_BUNDLE_SUPPORT'] = File.expand_path(
  File.dirname(File.dirname(__FILE__))
)

# -- Imports -------------------------------------------------------------------

require 'fileutils'
require 'find'
require 'optparse'
require 'pathname'
require 'rubygems'
require 'yaml'

if Gem::Version.new(RUBY_VERSION) < Gem::Version.new(2.2)
  require ENV['TM_BUNDLE_SUPPORT'] + '/lib/Ruby/lib/unf'
else
  # Ruby 2.2 already supports Unicode normalization
  class String
    alias to_nfc unicode_normalize
  end
end

# -- Classes -------------------------------------------------------------------

# This class implements a very basic option parser.
class ArgumentParser
  DESCRIPTION = %(
      clean — Remove auxiliary files created by various TeX commands

  Synopsis

      clean [-h|--help] [LOCATION]

  Description

    If LOCATION is a directory then this tool removes auxiliary files
    contained in the top level of the directory.

    If LOCATION is a file, then it removes all auxiliary files matching the
    supplied file name.

    If LOCATION is not specified, then clean removes auxiliary files in
    the current directory.
  ).freeze

  # This method parses all command line arguments.
  #
  # The function returns a string containing the path of an existing file if
  #
  # - +arguments+ is empty or
  # - +arguments+ contains only a single element that represents a valid path.
  #
  # If +arguments+ contains a path that does not exist, then the function
  # aborts program execution. The function also stops program execution if the
  # user asks the program to print a help message via a switch such as +-h+. In
  # this case the function prints a help message before it exits.
  #
  # = Arguments
  #
  # [arguments] This is a list of strings containing command line arguments.
  #
  # = Output
  #
  # This function returns a string containing a file location.
  #
  # = Examples
  #
  # doctest: Parse command line arguments containing an existing directory
  #
  #   >> ArgumentParser.parse ['Support']
  #   => 'Support'
  #
  # doctest: Parse command line arguments containing an existing file
  #
  #   >> ArgumentParser.parse ['Tests/TeX/packages.tex']
  #   => 'Tests/TeX/packages.tex'
  #
  # doctest: Parse empty command line arguments
  #
  #   >> ArgumentParser.parse([]) == Dir.pwd
  #   => true
  def self.parse(arguments)
    location = parse_options(arguments).join ''
    return Dir.pwd if location.empty?
    return location if File.exist? location

    warn "#{location}: No such file or directory"
    exit
  end

  class << self
    private

    def parse_options(arguments)
      option_parser = OptionParser.new do |opts|
        opts.banner = DESCRIPTION
        opts.separator "  Arguments\n\n"
        opts.on('-h', '--help', 'Prints this help') do
          puts opts
          exit
        end
      end
      option_parser.parse! arguments
    end
  end
end

# We extend the String class to allow substitution of simple variable patterns.
class String
  # This function replaces variable patterns in a string and returns the result.
  #
  # The variable patterns have one of the following two forms:
  #
  # 1. +${NAME}+
  # 2. +${NAME/pattern/replacement/}+
  #
  # . In the first case the function just replaces patterns of the form
  # +${NAME}+ by the string specified in the argument +name+.
  #
  # In the second case the function replaces all substring of the form +pattern+
  # with +replacement+ inside the string stored in the variable +name+. After
  # that the function substitutes the patterns of the form
  # `${NAME/pattern/replacement}` with the value of the string calculated in the
  # last step.
  #
  # = Arguments
  #
  # [name] This variable contains the value of the variable pattern +${NAME}+.
  #
  # [regex_escape_name] This variable specifies if the function should
  #                     regex-escape the replacement value.
  #
  # = Output
  #
  # The function returns a pattern substituted version of this string.
  #
  # = Examples
  #
  # doctest: Replace an occurrence of the variable `${NAME}`
  #
  #   >> '{before} ${NAME} {after} $NAME'.replace_name('By The Throat', false)
  #   => '{before} By The Throat {after} $NAME'
  #
  # doctest: Replace an occurrence of `${NAME/:)/😀/}`
  #
  #   >> '> ${NAME/:)/😀/} <'.replace_name(':) ^_^ :)', false)
  #   => '> 😀 ^_^ 😀 <'
  #
  # doctest: Replace an occurrence of `${NAME/-/o/}` and escape the replacement
  #
  #   >> '${NAME/-/o/}'.replace_name('- - -')
  #   => 'o\\ o\\ o'
  def replace_name(name, regex_escape_name = true)
    gsub(%r{\${NAME(?:\/([^\/]+)\/([^\/]+)\/)?}}).each do |_match|
      pattern = Regexp.last_match(1)
      replacement = Regexp.last_match(2)
      name = name.gsub(pattern, replacement) if pattern && replacement
      regex_escape_name ? Regexp.escape(name) : name
    end
  end
end

# This class saves information about auxiliary TeX files.
class Auxiliary
  CONFIG_FILE = "#{ENV['TM_BUNDLE_SUPPORT']}/config/auxiliary.yaml".freeze
  CONFIGURATION = YAML.load_file CONFIG_FILE

  def initialize(name)
    @name = name
  end

  # This method returns a list of regexes matching auxiliary directories.
  #
  # = Output
  #
  # This function returns a list of strings. Each string specifies a regular
  # expression that matches auxiliary TeX directories.
  #
  # = Examples
  #
  # doctest: Read the list of auxiliary directory regexes
  #
  #   >> Auxiliary.new('Bleed Under My Pen').directory_patterns
  #   => ['pythontex-files-Bleed\\-Under\\-My\\-Pen',
  #       '_minted-Bleed_Under_My_Pen']
  def directory_patterns
    CONFIGURATION['directories'].map do |pattern|
      pattern.to_s.replace_name(@name)
    end
  end

  # This method returns a list of regexes matching auxiliary files.
  #
  # = Output
  #
  # The function returns a list of strings. Each string specifies a regular
  # expression that matches auxiliary TeX files.
  #
  # = Examples
  #
  # doctest: Read the list of auxiliary file regexes
  #
  #   >> patterns = Auxiliary.new('Running With The Wolves').file_patterns
  #   >> patterns[0]
  #   => '\\.Running\\ With\\ The\\ Wolves\\.lb$'
  #   >> %w(aux ilg synctex\.gz).map { |ext| patterns[1].include? ext }.all?
  #   => true
  def file_patterns
    CONFIGURATION['files'].map { |pattern| pattern.to_s.replace_name(@name) }
  end
end

# We extend the directory class to support the removal of auxiliary TeX files.
class Dir
  # This function removes auxiliary files from the current directory.
  #
  # = Output
  #
  # The function returns a list of strings. Each string specifies the location
  # of a file this function successfully deleted.
  #
  # = Examples
  #
  # doctest: Remove auxiliary files from a directory
  #
  #   >> require 'tmpdir'
  #   >> test_directory = Dir.mktmpdir
  #
  #   >> filename = 'Hau Ab Die Schildkröte'
  #   >> aux_directories = ["_minted-#{filename.gsub ' ', '_'}",
  #                         "pythontex-files-#{filename.gsub ' ', '-'}"]
  #   >> non_aux_directories = ['Do Not Delete Me', '.git']
  #   >> all_directories = aux_directories + non_aux_directories
  #   >> all_directories.each do |filename|
  #        Dir.mkdir(File.join test_directory, filename)
  #        end
  #
  #   >> aux_files = ['Fjørt.aux', 'Fjørt.toc', '.Fjørt.lb',
  #                   'Wide Open Spaces.synctex.gz', '😱.glo']
  #   >> non_aux_files = ['Fjørt.tex', 'Wide Open Spaces', '🙈🙉🙊.txt',
  #                       '.git/pack.idx']
  #   >> all_files = aux_files + non_aux_files
  #   >> all_files.each do |filename|
  #        File.new(File.join(test_directory, filename), 'w').close
  #        end
  #
  #   >> deleted = Dir.new(test_directory).delete_aux
  #   >> deleted.map { |path| File.basename path } ==
  #      (aux_files + aux_directories).sort
  #   => true
  def delete_aux
    (FileUtils.rm(aux_files, :force => true) +
     FileUtils.rm_rf(aux_directories)).sort
  end

  private

  def aux(pattern_method, check_file)
    patterns = Auxiliary.new('FILENAME').send(pattern_method)
    patterns.map { |pattern| pattern.gsub!('FILENAME', '.+') }
    files.map(&:to_nfc).select do |filepath|
      patterns.any? { |pattern| filepath =~ /#{pattern}/x } &&
        check_file.call(filepath)
    end
  end

  def aux_files
    aux(:file_patterns, proc { |filename| File.file?(filename) })
  end

  def aux_directories
    aux(:directory_patterns, proc { |filename| File.directory?(filename) })
  end

  def files
    Find.find(path).map do |path|
      # Ignore files in hidden directories
      Find.prune if File.directory?(path) && File.basename(path) =~ /^\.[^.]/
      path.force_encoding('UTF-8')
    end
  end
end

# +TeXFile+ provides an API to remove auxiliary files produced for a specific
# TeX file.
class TeXFile
  def initialize(path)
    @path = Pathname.new path.to_nfc
    @basename = File.basename(@path, File.extname(@path))
  end

  # This function removes auxiliary files for a certain TeX file.
  #
  # = Output
  #
  # The function returns a list of strings. Each string specifies the location
  # of a file this function successfully deleted.
  #
  # doctest: Remove auxiliary files for specific TeX files
  #
  #   >> require 'tmpdir'
  #   >> test_directory = Dir.mktmpdir
  #
  #   >> aux_files = ['[A → B] Life.toc', 'Fjørt.aux', 'Fjørt.toc', '.Fjørt.lb',
  #                   'Wide Open Spaces.synctex.gz', '😘.glo']
  #   >> non_aux_files = ['Fjørt.tex', 'D.E.A.D. R.A.M.O.N.E.S.']
  #   >> all_files = aux_files + non_aux_files
  #   >> all_files.each do |filename|
  #        File.new(File.join(test_directory, filename), 'w').close
  #        end
  #
  #   >> filename = 'Hau Ab Die Schildkröte'
  #   >> aux_directories = ["_minted-#{filename.gsub ' ', '_'}",
  #                         "pythontex-files-#{filename.gsub ' ', '-'}",
  #                         '_minted-👻']
  #   >> non_aux_directories = ['Außer Dir', '.git']
  #   >> all_directories = aux_directories + non_aux_directories
  #   >> all_directories.each do |filename|
  #       Dir.mkdir(File.join test_directory, filename)
  #       end
  #
  #   >> tex_file = TeXFile.new(File.join test_directory, filename)
  #   >> tex_file.delete_aux.map { |path| File.basename path } ==
  #      aux_directories.select { |dir| dir.end_with? 'Schildkröte' }
  #   => true
  #
  #   >> tex_file = TeXFile.new(File.join test_directory, 'Fjørt')
  #   >> tex_file.delete_aux.map { |path| File.basename path }.length
  #   => 3
  #
  #   >> tex_file = TeXFile.new(File.join test_directory, '[A → B] Life.tex')
  #   >> tex_file.delete_aux.map { |path| File.basename path } ==
  #      aux_files.select { |file| file.start_with? '[A → B] Life' }
  #   => true
  def delete_aux
    (FileUtils.rm(aux_files, :force => true) +
     FileUtils.rm_rf(aux_directories)).sort
  end

  private

  def aux(pattern_method, check_file)
    patterns = Auxiliary.new(@basename).send(pattern_method)
    Dir.chdir(@path.parent) do
      Dir['{**/*,.[^.]*}'].map { |path| path.to_s.to_nfc }.select do |filepath|
        patterns.any? { |pattern| filepath =~ /#{pattern}/x } &&
          check_file.call(filepath)
      end
    end
  end

  def aux_files
    aux(:file_patterns, proc { |filename| File.file?(filename) })
  end

  def aux_directories
    aux(:directory_patterns, proc { |filename| File.directory?(filename) })
  end
end

# -- Main ----------------------------------------------------------------------

if $PROGRAM_NAME == __FILE__
  location = ArgumentParser.parse(ARGV)
  tex_location = if File.directory?(location) then Dir.new(location)
                 else TeXFile.new(location)
                 end
  tex_location.delete_aux.map { |path| puts(File.basename(path)) }
end
