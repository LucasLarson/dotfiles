# ------------------------------------------------------------------------------
#                   Run various tests for this bundle
#
# To execute the tests:
#
#   1. Open the root folder of this bundle inside TextMate
#   2. Run the command “Build” (⌘B) located inside the Make bundle
#
# The tests require the following test frameworks:
# - [tox](https://tox.readthedocs.org)
# - [cram](https://bitheap.org/cram/)
# - [nose](http://nose.readthedocs.org)
# - [rubydoctest](https://github.com/tablatom/rubydoctest)
#
# and the following code checkers:
# - [flake8](https://pypi.python.org/pypi/flake8)
# - [perlcritic](http://search.cpan.org/dist/Perl-Critic/bin/perlcritic)
# - [rubocop](https://github.com/bbatsov/rubocop)
#
# For all tests to work correctly you also need to install:
# 1. “Skim” inside the folder `/Applications` and
# 2. [gtm](http://lists.macromates.com/textmate/2010-May/030881.html) in a
# 	 location accessible via `PATH`.
# ------------------------------------------------------------------------------

.PHONY: checkstyle cramtests perltests rubydoctests toxtests

# -- Variables -----------------------------------------------------------------

# We need to set the bundle support location to the support folder of the LaTeX
# bundle. If we do not set this variable explicitly, then `TM_BUNDLE_SUPPORT`
# will be set to the location of the bundle support folder for the `Make`
# bundle. This will lead to errors since `latex_watch` expects that
# `TM_BUNDLE_SUPPORT` is set “correctly”.
export TM_BUNDLE_SUPPORT = $(CURDIR)/Support
# We need to export `TM_SUPPORT_PATH` if we test the code outside of TextMate
BUNDLE_DIR = $(HOME)/Library/Application Support/TextMate/Managed/Bundles
export TM_SUPPORT_PATH = $(BUNDLE_DIR)/Bundle Support.tmbundle/Support/shared

TEXTMATE_DIR = /Applications/TextMate.app/Contents
DIALOG_DIR = $(TEXTMATE_DIR)/PlugIns/Dialog2.tmplugin/Contents
TM_PID = $(shell pidof Textmate | cut -f 1 -d ' ' | sed -E 's/[[:space:]]+//')

export TM_MATE = $(TEXTMATE_DIR)/Resources/mate
export DIALOG = $(DIALOG_DIR)/Resources/tm_dialog2
export DIALOG_PORT_NAME = com.macromates.dialog.$(TM_PID)

BINARY_DIRECTORY = Support/bin
LIBRARY_DIRECTORY = Support/lib
RUBY_FILES = $(BINARY_DIRECTORY)/clean.rb \
			 $(LIBRARY_DIRECTORY)/Ruby/*.rb \
			 $(LIBRARY_DIRECTORY)/Ruby/{completion,project_management}/*.rb

# -- Rules ---------------------------------------------------------------------

run: all

all: toxtests cramtests perltests rubydoctests

clean:
	cd Tests/TeX && rm -vf *.acr *.alg *.bbl *.blg *.dvi *.fdb_latexmk *.fls \
		*.glg *.gls *.ilg *.ind *.log *.ps *.pdf

# ================
# = Style Checks =
# ================

checkstyle: checkstyle_perl checkstyle_python checkstyle_ruby

checkstyle_perl:
	perlcritic --harsh $(LIBRARY_DIRECTORY)/Perl/*.pm Tests/Perl/*.t
	perlcritic $(BINARY_DIRECTORY)/latex_watch.pl

checkstyle_python:
	flake8 $(BINARY_DIRECTORY)/*.py $(LIBRARY_DIRECTORY)/Python/*.py

checkstyle_ruby:
	rubocop $(RUBY_FILES)

# =========
# = Tests =
# =========

cramtests:
	cd Tests/Cram/General && cram *.t

perltests: checkstyle_perl
	perl Tests/Perl/*.t

rubydoctests: checkstyle_ruby
	rubydoctest $(RUBY_FILES)

toxtests: checkstyle_python
	tox
