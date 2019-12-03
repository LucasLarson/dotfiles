-- Setup ----------------------------------------------------------------------

  $ cd "$TESTDIR"
  $ source ../../lib/setup_cram.sh
  $ cd ../../TeX/

-- Tests ----------------------------------------------------------------------

If we check the tex file with `chktex` we should not get any warning at all.
This means grep will fail and therefore return the status value 1.

  $ texmate.py 'chktex' external_bibliography.tex | grep 'Warning:'
  [1]
