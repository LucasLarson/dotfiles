package Latex;

# -- Imports -------------------------------------------------------------------

use strict;
use warnings;

use Carp qw( croak );
use Cwd qw( realpath );
use Exporter qw( import );
use File::Basename;
use File::Spec;

# -- Exports -------------------------------------------------------------------

our @EXPORT_OK = qw(guess_tex_engine master tex_directives);

# -- Functions -----------------------------------------------------------------

# Guess the TeX engine which should be used to translate a certain TeX-file.
#
# Arguments:
#
#      filepath - The file path of the TeX file.
#
# Returns:
#
#      A string containing the TeX engine for the given file or an empty
#      string if the engine could not be determined.
#
sub guess_tex_engine {
    my ($filename) = @_;
    my $engine     = "";
    my %directives = tex_directives($filename);

    $engine = $directives{"program"} if ( exists $directives{"program"} );
    return $engine;
}

# Read `%! TEX` directives from a given file.
#
# Arguments:
#
#      filepath - The file path of the TeX file.
#
# Returns:
#
#      A hash containing the tex directives for the given file.
#
sub tex_directives {
    my ($filename) = @_;
    open( my $fh, "<", $filename )
      or croak "Can not open $filename: $!";
    my %directives = _tex_directives_filehandle($fh);
    close($fh);
    return %directives;
}

# Get the master file for the specified TeX file.
#
# Arguments:
#
#      filepath - The file path of the TeX file.
#
# Returns:
#
#       This function returns an array of the form:
#
#           ( $error, $filepath_or_error_message )
#
#       `$error` specifies if there was an error determining the master file. If
#       `$error` is false, then `$filepath_or_error_message` contains the
#       correct path to the master file. Otherwise the second value of the
#       array contains an error message describing the problem encountered
#       while determining the master file.
#
sub master {
    my ($current_file) = @_;
    my $master;
    my %directives;
    my %filepaths = ();

    while ( !exists $filepaths{$current_file} ) {
        $filepaths{$current_file} = undef;
        %directives = tex_directives($current_file);
        return ( 0, $current_file ) unless exists $directives{"root"};
        $master = $directives{"root"};
        $master = File::Spec->catfile( scalar( dirname $current_file), $master )
          unless File::Spec->file_name_is_absolute($master);
        $master = realpath($master);
        return ( 1,
                "The root $master specified in the file $current_file can not "
              . "be opened" )
          unless -r $master;
        $current_file = $master;
    }

    return ( 1,
            "The file $current_file was specified twice as root file."
          . " Please check your root directives for loops" );
}

# ===========
# = Private =
# ===========

sub _tex_directives_filehandle {
    my ($fh) = @_;
    my %directives = ();

    # TS-program is case insensitive e.g. `LaTeX` should be the same as `latex`
    my $engines = "(?i)latex|lualatex|pdflatex|xelatex(?-i)";
    my $keys    = "encoding|spellcheck|root";

    while ( my $line = <$fh> ) {
        last unless ( 1 .. 20 );
        next unless ( $line =~ m{^ \s*%\s* !T[e|E]X}x );

        $line =~ s/^ \s*%\s* !T[e|E]X \s* | \s+$//x;

        if ( $line =~ m{(?:TS-)?program \s* = \s* ($engines)}x ) {
            $directives{"program"} = lc($1);
        }
        elsif ( $line =~ m{($keys) \s* = \s* (.+)}x ) {
            $directives{$1} = $2;
        }
    }

    return %directives;
}

1;
