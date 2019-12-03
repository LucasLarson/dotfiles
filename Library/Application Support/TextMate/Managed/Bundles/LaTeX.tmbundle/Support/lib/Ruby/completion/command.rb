# -- Imports -------------------------------------------------------------------

require ENV['TM_SUPPORT_PATH'] + '/lib/exit_codes'
require ENV['TM_BUNDLE_SUPPORT'] + '/lib/Ruby/command'
require ENV['TM_BUNDLE_SUPPORT'] + '/lib/Ruby/latex'

# -- Functions -----------------------------------------------------------------

# Insert a command based on the current word into the document.
def command_completion
  print(menu_choice_exit_if_empty(completions))
rescue RuntimeError => e
  TextMate.exit_show_tool_tip(e.message)
end

# This function returns a list of completion commands for the current file.
#
# = Output
#
# The function returns a list of strings. Each item of the list represents a
# LaTeX command.
def completions
  completions = (File.open(ENV['TM_BUNDLE_SUPPORT'] + '/config/completions.txt',
                           'r').read.split("\n") + LaTeX.commands).uniq
  current_word = ENV['TM_CURRENT_WORD']
  completions.delete(current_word)
  completions.grep(/^#{current_word}/).sort
end
