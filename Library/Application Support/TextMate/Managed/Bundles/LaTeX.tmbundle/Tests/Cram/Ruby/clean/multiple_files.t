-- Setup -----------------------------------------------------------------------

  $ source "$TESTDIR/setup.sh"
  $ cp "$TEX_DIRECTORY/references.tex" \
  >    "$TEX_DIRECTORY/"{more_,}references.bib .
  $ mkdir input
  $ cp "$TEX_DIRECTORY/input/references_input.tex" input
  $ cp "$TEX_DIRECTORY/ünicöde.tex" .

-- Test ------------------------------------------------------------------------

Create some auxiliary files

  $ latexmk -lualatex references.tex 2>&- | tail -n 1
  Latexmk: All targets (references.pdf) are up-to-date
  $ latexmk -xelatex ünicöde.tex 2>&- | tail -n 1
  Latexmk: All targets (\xfcnic\xf6de.pdf) are up-to-date (esc)

Delete all auxiliary file created for references.tex

  $ clean.rb references.tex
  references.aux
  references.bbl
  references.bcf
  references.blg
  references.fdb_latexmk
  references.fls
  references.log
  references.run.xml

The directory still contains the auxiliary files for ünicöde.tex

  $ find . -name '*nic*de.*'
  ./ünicöde.aux
  ./ünicöde.fdb_latexmk
  ./ünicöde.fls
  ./ünicöde.log
  ./ünicöde.pdf
  ./ünicöde.tex

Remove the remaining the auxiliary files

  $ clean.rb > /dev/null

The folder now only contains the PDF and the TeX file

  $ ls
  input
  more_references.bib
  references.bib
  references.pdf
  references.tex
  ünicöde.pdf
  ünicöde.tex
