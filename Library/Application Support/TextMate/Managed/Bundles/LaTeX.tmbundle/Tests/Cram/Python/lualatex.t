-- Setup ----------------------------------------------------------------------

  $ cd "$TESTDIR"
  $ source ../../lib/setup_cram.sh
  $ cd ../../TeX/

-- Tests ----------------------------------------------------------------------

Just try to translate the program using `latex`

  $ texmate.py version lualatex.tex
  This is LuaTeX, Version * (glob)

  $ texmate.py -suppressview latex -latexmk no -engine lualatex lualatex.tex \
  > | grep 'Output written' |  countlines
  1

Check if clean removes all auxiliary files.

  $ texmate.py clean lualatex.tex > /dev/null; exit_success_or_discard
  $ ls | grep -E $auxiliary_files_regex
  [1]

-- Cleanup --------------------------------------------------------------------

Restore the file changes made by previous commands.

  $ restore_aux_files_git

Remove the generated PDF files

  $ rm -f *.pdf
