-- Setup ----------------------------------------------------------------------

  $ cd "$TESTDIR"
  $ source ../../lib/setup_cram.sh
  $ cd ../../TeX/

-- Tests ----------------------------------------------------------------------

We test if the root directive (%!TEX root) works. This means that although we
call typesetting on a certain file, we translate the file specified as
`root`.

  $ export TM_FILEPATH="input/packages_input1.tex"

Just try to translate the program using `latex`. The root file is
`packages.tex`

  $ texmate.py -s latex -latexmk no | grep 'packages.tex' | countlines
  1

Check if clean removes all auxiliary files.

  $ texmate.py clean > /dev/null; exit_success_or_discard
  $ ls | grep -E $auxiliary_files_regex
  [1]

-- Cleanup --------------------------------------------------------------------

Restore the file changes made by previous commands.

  $ restore_aux_files_git

Remove the generated PDF files

  $ rm -f *.pdf
