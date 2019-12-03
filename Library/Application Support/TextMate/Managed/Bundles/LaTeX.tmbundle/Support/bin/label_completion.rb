#!/usr/bin/ruby

# -- Imports -------------------------------------------------------------------

require ENV['TM_BUNDLE_SUPPORT'] + '/lib/Ruby/latex.rb'

# -- Main ----------------------------------------------------------------------

puts(LaTeX.label_names.join("\n"))
