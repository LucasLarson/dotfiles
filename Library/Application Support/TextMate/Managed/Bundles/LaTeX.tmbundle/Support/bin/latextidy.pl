#!/usr/bin/perl

# LaTeXTidy (c) 2004 by Eric Hsu <textmate@betterfilecabinet.com>.

# Little Perl script to neaten up the format of LaTeX files.
# This will be simple and naive. This takes STDIN .tex files and prints to
# STDOUT.
# Check your file! Backup! No guarantees!

# License
# -------
# This is released as Niceware, which is like the Perl Artistic License, except
# you have to be nice to me when you criticize the code.

# General Idea
# ------------

# Eat all single newlines. Add newlines after all "\\"
# Newlines before each \begin and \end. After each \end{}
# Each environment \begin adds a level of tab.
# Newlines before each \item.
# \n before each \[  and after each \]

my $in = "";

while (<STDIN>) {
    $in .= $_;
}

my @keywords = qw(
  # LaTeX, AMX LaTeX, AMS TeX, Plain TeX

  (front|main|back)matter
  (h|v)size
  (new)?theoremstyle
  (re)?new(theorem|environment|counter|font|line|page|command|symbol)
  (small|med|big|par)skip
  (special|sub|subsub|subsubsub)?section
  address
  appendix
  author
  bibliography(style)?
  caption
  centerline
  chapter
  contrib
  curraddr
  date
  DeclareMathOperator
  dedicatory
  def
  document
  document(class|style)
  email
  end
  evensidemargin
  font
  headheight
  headsep
  include(only)?
  includegraphics
  indent
  index
  input
  keywords
  loadmsam
  loadmsbm
  magnification
  make(title|index)
  noindent
  numberwithin
  oddsidemargin
  page(style|break|numbering)
  paragraph
  part
  printbibliography
  printindex
  ragged(bottom|left|right)
  set(counter|length|beamertemplate|beamercolor)
  setto(width|height|depth)
  subjclass
  swapnumbers
  table
  text(height|width)
  thanks
  title
  topmargin
  translator
  urladdr
  use(package|box|counter|command)
  UseAMSsymbols
  vfill?

  # TikZ

  clip
  coordinate
  draw
  fill
  filldraw
  foreach
  node
  path
  shade
  tikz(aliascoordinatesystem|declarecoordinatesystem|set|setnextfilename|style)
  use(asboundingbox|tikzlibrary)

);

my $indentation =
  $ENV{'TM_SOFT_TABS'} eq 'YES' ? ' ' x $ENV{'TM_TAB_SIZE'} : "\t";

# Let's ignore all comments in the following way. We first find all \%(.*?)\n.
# Then we put a second \n at the end, and two leading \n
# to ensure that they all land in
# separate pieces. Then each piece that has a leading % is immediately passed.

$in =~ s/(?<!\\)\%(.*?)\n/\n\n\%$1\n\n/g;

my @pieces = split( /\n\s*\n/, $in );
my $string = "";
my $keyword;

foreach (@pieces) {

    # Every comment is left as is. Ignore % that are immediately preceded by \
    if (/^\s*(?<!\\)\%/) {
        $string .= $_ . "\n";
        next;
    }

    # Eat all single newlines.

    s/\s+/ /g;

    # Put @keywords on their own line.

    foreach $keyword (@keywords) {
        s/\\$keyword\b/\n$&/g;
    }

    # Newlines before each \begin and \end. After each \end{}
    # We want to ignore begin and end document, since those shouldn't
    # induce additional indenting

    s/([^\\]\%)/\n$1/g;

    s/(\\begin\{)((?!document).*?)(\})/\n$1$2$3\n/g;
    s/(\\end\{)((?!document).*?)(\})/\n$1$2$3\n/g;
    s/(\\begin\{array\})\n(\{)(.*?)(\})/\n$1$2$3$4\n/g;

    # Newlines before each \item.

    s/(\\item)(.*?)(\\item)/$1$2\n$3/g;
    s/(\\item)/\n$1/g;

    # Newlines before each \bibitem.

    s/(\\bibitem)(.*?)(\\bibitem)/$1$2\n$3/g;
    s/(\\bibitem)/\n$1/g;

    # \n before each \[  and after each \]
    # Add newlines after all "\\", "\cr", and "\\[...]"

    s/[^\\](\\\[)/\n$1/g;
    s/(\\\])/$1\n/g;

    s/(\\\\|\\cr)\s/$1\n/g;
    s/(\\\\\[)(.*?)(\])\s/$1$2$3\n/g;

    # Nuke accidentally added double newlines.

    s/\n\s*\n/\n/g;

    # Collect the cleaned string.

    s/^\n//;
    chomp;
    $string .= $_ . "\n\n";

}

# First let's collapse all multiple \n's into double \n.

$string =~ s/\n\s+\n/\n\n/g;

# We will soon mark the \end and \begin keywords, but we want to ignore ones
# found as comments. Hence we'll (awful kludge) wedge in a \{\n\n\n\} to
# commented \begin and \end to avoid their processing.
# We'll fix them right after the pieces are split.

$string =~ s/(\%[^\n]*)(\\)(end)/$1$2\{\n\n\n\}$3/g;
$string =~ s/(\%[^\n]*)(\\)(begin)/$1$2\{\n\n\n\}$3/g;

# Now let's put [triple \n] at the start of each \begin and the start of each
# \end. Then we'll split on them, since they are unique.
# Each of those pieces must be at the same indent level. Again, we need to
# ignore beginning and end of document.

#$string =~s/(\\end)/\[\n\n\n$\]$1/g;
#$string =~s/(\\begin)/\[\n\n\n$\]$1/g;
#
#@pieces = split(/\[\n\n\n$\]/, $string);

$string =~ s/(\\end(?!\{document\}))/\[\n\n\n\]$1/g;
$string =~ s/(\\begin(?!\{document\}))/\[\n\n\n\]$1/g;

@pieces = split( /\[\n\n\n\]/, $string );

my $indent = 1;
my @lines;
my ( $piece, $i );

# $string is now free for reuse.
$string = "";

foreach $piece (@pieces) {

    # First, is this a begin block, or after an end block?

    $piece =~ s/\{\n\n\n\}//g;    #get rid of awful kludge.
    $piece =~ /^\\(.*?)\{/;
    if ( lc($1) eq "begin" ) {
        $indent++;
    }
    else {
        $indent--;
    }

    # Each piece is split on \n. these pieces must begin with $indent tabs.
    # We need to avoid combining comment lines with others.

    @lines = split( /\n/, $piece );

    foreach (@lines) {
        s/^\s+//;    # No leading whitespace
        if (/^\\begin/i) {
            for ( $i = 1 ; $i <= $indent - 1 ; $i++ ) {
                $string .= $indentation;
            }
        }
        else {
            for ( $i = 1 ; $i <= $indent ; $i++ ) {
                $string .= $indentation;
            }
        }
        $string .= $_ . "\n";
    }

}

# At this point each \label appears on a line of its own.
# This hack is designed to restore \labels next to \begin, \end and suchlike
# so that code folding leaves the \label visible.
my $option = '(\[[^\]]*\][ \t]*)';
my $arg    = '({[^}]*}[ \t]*)';
$string =~ s/(?<argument>${arg})
		(?<newline_then_indent>\n[ \t]*)
		(?<options_then_labels>${option}*(\\label[ \t]*${option}?${arg})+)
		\n?[ \t]*
	/$+{argument}$+{options_then_labels}$+{newline_then_indent}/mgx;
$string =~ s/(?<labels>(\\label[ \t]*${option}?${arg})+)
		(?<newline_then_indent>\n[ \t]*)
		(?<end_argument>\\end{[^}]*})
	/$+{newline_then_indent}$+{labels}$+{end_argument}/mgx;
$string =~ s/(?<labelled_section>\\section.*(\\label[ \t]*${option}?${arg})+)
		(?<paragraph>\S)
	/$+{labelled_section}\n$+{paragraph}/mgx;

# Add blank lines before \sections and \subsections
$string =~ s/(?<=\S)[ \t]*(?:\n[ \t]*){0,2}(\\section)/\n\n\n$1/mg;
$string =~ s/(?<=\S)[ \t]*(?:\n[ \t]*){0,1}(\\subsection)/\n\n$1/mg;

# End of hack

print $string;

# (0.1)  First version works. It indents LaTeX more or less correctly.
# (0.2)  Added a big list of LaTeX words to check. Squashed bug losing double
#        lines. Handles comments. Handles sections, more or less. (5/3/02)
# (0.21) Pushed keywords out to its own array. Added some more keywords.
#        (5/4/02)
# (0.22) Trying to ignore comments.
# (0.23) Trying to port it to BBEdit.
# (0.3)  Now for TextMate.
# (0.31) Neating the code so strict mode doesn't complain as much.

# To Do.
# Not catching \usecommand!
#  Take all such \sections
#  and give the header a line of its own?
