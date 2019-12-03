# -- Imports -------------------------------------------------------------------

require 'yaml'

# -- Class ---------------------------------------------------------------------

# We extend the string class to support transformation of character sequences.
class String
  config = YAML.load_file("#{ENV['TM_BUNDLE_SUPPORT']}/config/conversion.yaml")

  WORD_TO_CHARACTER = config['word_to_character'].freeze

  CHARACTER_TO_SYMBOL = config['character_to_symbol'].freeze

  # This method converts certain sequences of characters to LaTeX symbols.
  #
  # It replaces special characters like +↔+, and special character sequences
  # like +=>+, with their LaTeX command equivalents.
  #
  # = Output
  #
  # The function returns a modified copy of the current string.
  #
  # = Examples
  #
  # doctest: Convert single arrow character to LaTeX command
  #
  #   >> '[A→B] Life'.convert
  #   => '[A\rightarrowB] Life'
  #
  # doctest: Convert “<==”, “⇔” and “<=>” to LaTeX command
  #
  #   >> '<== ⇔ <=>'.convert
  #   => '\Longleftarrow \Leftrightarrow \Leftrightarrow'
  def convert
    word_regex = Regexp.union(WORD_TO_CHARACTER.keys.sort_by(&:length).reverse)
    converted = gsub(word_regex) { |match| WORD_TO_CHARACTER[match] }
    char_regex = Regexp.union(CHARACTER_TO_SYMBOL.keys)
    converted.gsub(char_regex) { |match| CHARACTER_TO_SYMBOL[match] }
  end
end
