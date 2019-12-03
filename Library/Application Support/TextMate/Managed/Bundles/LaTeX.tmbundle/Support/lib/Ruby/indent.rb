# Return a string representing a certain level of indentation.
#
# This function respects the current tab settings of the user.
#
# = Arguments
#
# [times] The number of times the text following the string returned by this
#         function should be indented.
#
# = Output
#
# A string that represents a certain level of indentation
def indent(times = 1)
  if ENV['TM_SOFT_TABS'] == 'NO' then "\t" * times
  else ' ' * ENV['TM_TAB_SIZE'].to_i * times
  end
end
