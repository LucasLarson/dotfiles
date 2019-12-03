#! /usr/bin/perl

# LaTeX Watch,
#  - by Robin Houston, 2007, 2008.
#  - by René Schwaiger, 2014, 2015.

# Usage: latex_watch.pl [ options ] file.tex
#
# Options:
#  --debug, -d             Pop up dialog boxes containing debugging info
#  --debug-to-console      Print debugging messages to stdout
#  --textmate-pid <pid>    Exit if the process <pid> disappears
#  --progressbar-pid <pid> Kill <pid> after the document has been compiled for
#                          the 1st time
#
# Example usage using `fish` (http://fishshell.com):
#
#   set tm_pid (pgrep TextMate); and LaTeX.tmbundle/Support/bin/latex_watch.pl \
#       -d --textmate-pid=$tm_pid path/to/texfile.tex
#

use strict;
use warnings;

use Cwd qw(abs_path);
use Env qw(DIALOG DISPLAY HOME PATH TM_APP_IDENTIFIER TM_BUNDLE_SUPPORT
  TM_SUPPORT_PATH);
use File::Basename;
use File::Copy 'copy';
use Getopt::Long qw(GetOptions :config no_auto_abbrev bundling);
use POSIX ();
use Time::HiRes 'sleep';

use lib dirname( dirname abs_path $0) . '/lib/Perl';
use Latex qw(guess_tex_engine master);

our $VERSION = "3.1415";

#############
# Configure #
#############

print "Latex Watch $VERSION: @ARGV\n";
init_environment();

my ( $DEBUG, $textmate_pid, $progressbar_pid ) = parse_command_line_options();
my ( $filepath, $wd, $name, $absolute_wd ) = parse_file_path();

my %prefs = get_prefs();
my ( $mode, $viewer, @tex );

@tex = qw(latexmk -interaction=nonstopmode);
push( @tex, "-r '$TM_BUNDLE_SUPPORT/config/latexmkrc'" );
if ( $prefs{engine} eq 'latex' ) {
    $mode = "PS";

    # Set $DISPLAY to a sensible default, if it's unset
    $DISPLAY = ":0"
      unless defined $DISPLAY;

    applescript('tell application "XQuartz" to launch');

    # Add Fink path
    $PATH .= ":/sw/bin";

    push( @tex, qw(-ps) );

    select_postscript_viewer();
}
elsif ($prefs{engine} eq "lualatex"
    || $prefs{engine} eq "pdflatex"
    || $prefs{engine} eq "xelatex" )
{
    $mode = "PDF";
    push( @tex,
            "-pdf -pdflatex='$prefs{engine} $prefs{options} -synctex=1 "
          . "-file-line-error-style'" );

    if ( $prefs{viewer} eq 'TextMate' ) {
        print "Latex Watch: Cannot use TextMate to preview.",
          "Using default viewer instead.\n";
        $viewer = select_pdf_viewer();
    }
    else {
        $viewer = select_pdf_viewer( $prefs{viewer} );
    }
}

init_cleanup();
main_loop();

##################
# TextMate prefs #
##################

{
    my ( $prefs_file, $prefs );

    sub init_prefs {
        eval { require Foundation };
        if ( $@ ne "" ) {
            fail(
                "Couldn't load Foundation.pm",
                "The Perl module Foundation.pm could not be loaded. If you "
                  . "have been foolish enough to remove the default Perl "
                  . "interpreter (/usr/bin/perl), you must install "
                  . "PerlObjCBridge manually.\n\n$@\0"
            );
        }

        $TM_APP_IDENTIFIER ||= "com.macromates.textmate";
        $prefs_file = "$HOME/Library/Preferences/$TM_APP_IDENTIFIER.plist";
        $prefs      = NSDictionary->dictionaryWithContentsOfFile_($prefs_file);
    }

    sub getPreference {
        my ( $prefName, $default ) = @_;
        init_prefs() unless defined $prefs;

        my $pref = $prefs->objectForKey_($prefName);
        return $$pref ? $pref->UTF8String() : $default;
    }
}

sub get_prefs {
    my $engine = guess_tex_engine("$absolute_wd/$name.tex");
    debug_msg("Found type setting program: $engine");
    $engine = getPreference( latexEngine => "pdflatex" ) if $engine eq "";
    return (
        engine  => $engine,
        options => getPreference( latexEngineOptions => "" ),
        viewer  => getPreference( latexViewer => "TextMate" ),
    );
}

##################
# Setup routines #
##################

sub init_environment {

    # Add MacTeX
    $PATH .= ":/Library/TeX/texbin/";
    $PATH .= ":/usr/texbin";

    # If TM_SUPPORT_PATH or TM_BUNDLE_SUPPORT are undefined, make a plausible
    # guess. (Useful for running this script from outside TextMate.)
    $TM_SUPPORT_PATH =
        "$HOME/Library/Application Support/"
      . "TextMate/Managed/Bundles/Bundle Support.tmbundle/Support/shared"
      if !defined $TM_SUPPORT_PATH;
    if ( !defined $TM_BUNDLE_SUPPORT ) {
        $TM_BUNDLE_SUPPORT = dirname( dirname abs_path $0);
    }

    # Add TextMate support paths
    $PATH .= ":$TM_SUPPORT_PATH/bin";
    $PATH .= ":$TM_BUNDLE_SUPPORT/bin";

    # Location of CocoaDialog binary
    init_CocoaDialog( "$TM_SUPPORT_PATH/bin/CocoaDialog.app"
          . "/Contents/MacOS/CocoaDialog" );

}

sub parse_command_line_options {
    my ( $DEBUG, $textmate_pid, $progressbar_pid );

    GetOptions(
        'debug|d|debug-to-console' => \$DEBUG,
        'textmate-pid=i'           => \$textmate_pid,
        'progressbar-pid=i'        => \$progressbar_pid,
      )
      or fail(
        "Failed to process command-line options",
        "Check the console for details"
      );

    return ( $DEBUG, $textmate_pid, $progressbar_pid );
}

sub parse_file_path {
    my $filepath = shift(@ARGV);
    my $error;
    fail( "File not saved", "You must save the file before it can be watched" )
      if !defined($filepath)
      or $filepath eq "";

    ( $error, $filepath ) = master($filepath) if -r $filepath;

    # filepath contains error message in case of error
    fail( "Incorrect master file", $filepath ) if $error;

    # Parse and verify file path
    my ( $wd, $name, $absolute_wd );
    if ( $filepath =~ m!(.*)/! ) {
        $wd = $1;
        my $fullname = $';
        if ( $fullname =~ /\.tex\z/ ) {
            $name = $`;
        }
        else {
            fail(
                "Filename doesn't end in .tex",
                "The filename ($fullname) does not end with the .tex extension"
            );
        }
    }
    else {
        fail( "Path does not contain /",
            "The file path ($filepath) does not contain a '/'" );
    }
    if ( !-W $wd ) {
        fail( "Directory not writeable", "I can't write to the directory $wd" );
    }

    # Use a relative path, because TeX has problems with special characters in
    # the pathname
    chdir( $absolute_wd = $wd );
    $wd = ".";

    return ( $filepath, $wd, $name, $absolute_wd );
}

# Persistent state
my ( %files_mtimes, $cleanup_viewer, $ping_viewer, $notification_token,
    $typesetting_errors );

#############
# Main loop #
#############

sub main_loop {
    my $ping_counter = 10;
    $typesetting_errors = 0;
    $notification_token = '';
    while (1) {
        if ( document_has_changed() ) {
            debug_msg("Reloading file");
            my ( $output_exists, $error ) = compile();
            view() if $output_exists;
            parse_log($error);
            if ( defined($progressbar_pid) ) {
                debug_msg("Closing progress bar window ($progressbar_pid)");
                kill( 9, $progressbar_pid )
                  or fail("Failed to close progress bar window: $!");
                undef $progressbar_pid;
            }
        }

        # Every 5 times through the loop, check if viewer and/or TextMate are
        # still open
        if ( defined($ping_viewer) and 0 == $ping_counter-- ) {
            $ping_counter = 5;
            if ( not $ping_viewer->() ) {
                debug_msg("Viewer appears to have been closed. Exiting.");
                exit;
            }

            process_is_running($textmate_pid)
              or do {
                debug_msg("TextMate appears to have been closed. Exiting.");
                exit;
              };
        }

        sleep(0.5);
    }
}

####################
# Cleanup routines #
####################

# Clean up if we're interrupted or die
sub clean_up {
    debug_msg("Cleaning up");
    fail_unless_system( "clean.rb", "$filepath" );
    $cleanup_viewer->() if defined $cleanup_viewer;
    if ( defined($progressbar_pid) ) {
        debug_msg("Closing progress bar window as part of cleanup");
        kill( 9, $progressbar_pid );
    }
    close_notification_window() if defined($notification_token);
    if ( defined $name ) {
        unlink "$wd/.$name.watcher_pid"    # Do this last
          or debug_msg("Failed to unlink $wd/.$name.watcher_pid: $!");
    }
}
END { clean_up() }

sub init_cleanup {
    $SIG{INT} = $SIG{TERM} = sub { exit(0) };
}

######################
# Main loop routines #
######################

sub process_is_running {
    my ($pid) = @_;
    my $procinfo = `ps -xp $pid`;
    return ( $procinfo =~ y/\n// > 1 );
}

# Check whether the document, or any of its dependencies, has changed
sub document_has_changed {
    return 1 if keys(%files_mtimes) == 0;

    my $change = 0;

    foreach_modified_file(
        \%files_mtimes,
        sub {
            my ($file) = @_;
            debug_msg("The file '$file' has changed.");
            $change = 1;
        }
    );

    return $change;
}

sub foreach_modified_file {
    my ( $hash, $callback ) = @_;

    while ( my ( $file, $mtime ) = each %$hash ) {
        my $current_mtime = -M $file;
        if (
            !defined(
                $current_mtime)    # Error: probably input file moved or deleted
            || $current_mtime < $mtime
          )
        {
            if ( defined $current_mtime ) {
                $hash->{$file} = $current_mtime;
            }
            else {
                delete $hash->{$file};
            }
            $callback->($file);
        }
    }
}

sub parse_file_list {
    my ($hash) = @_;

    open( my $f, "<", "$wd/$name.fls" )
      or fail( "Failed to open file list",
        "I couldn't open the file '$wd/$name.fls': $!" );
    local $/ = "\n";

    my %updated_files;

    # Skip font files, .aux, .ini files and files produced by the minted package
    my $ignored_files_pattern =
      '/dev/null|\.(?:fd|tfm|aux|ini|aex|mintedcmd|mintedmd5|pyg|w18)$';

    while (<$f>) {
        if (/^(INPUT|OUTPUT) (.*)/) {
            my ( $t, $f ) = ( $1, $2 );

            next if $f =~ m!$ignored_files_pattern!;
            $f = "$wd/$f" if $f !~ m(/);

            my $mtime = -M ($f);
            if ( $t eq 'INPUT' ) {
                if ( defined $mtime ) {
                    if ( !exists $hash->{$f} ) {
                        debug_msg("[x] $f");
                        $hash->{$f} = $mtime;
                    }
                }
                else {
                    # Probably the file no longer exists. Warn but continue.
                    print(
                        "[LaTeX Watch] ",
                        "Failed to find the modification time of the file '$f'"
                          . " while parsing the file list: $!\n"
                    );
                }
            }
            else {    # $t eq 'OUTPUT'
                $updated_files{$f} = $mtime;
            }
        }
        elsif ( !/^PWD / ) {
            debug_msg("Unrecognised line in file list: $_");
        }
    }

    while ( my ( $f, $mtime ) = each %updated_files ) {
        $files_mtimes{$f} = $mtime
          if exists $files_mtimes{$f} and defined $mtime;
    }
    debug_msg( "Parsed file list: found " . keys(%$hash) . " files" );
}

my ( $compiled_document, $compiled_document_name );

sub compile {
    my $error = 0;

    fail_unless_system(
        "@tex '$wd/$name.tex' &> '$name.latexmk.log'",
        sub {
            if ( $? == 1 || $? == 2 || $? == 12 ) {

                # An error in the document
                debug_msg("Typesetting command failed with error code $?\n");
                $error = 1;
            }
            else {
                fail( "Failed to compile document",
                    "The command '@_' exited with unexpected error code $?" );
            }
        }
    );

    parse_file_list( \%files_mtimes );

    if ( $mode eq 'PS' ) {
        if ( -e "$wd/$name.ps" ) {
            $compiled_document      = "$wd/$name.ps";
            $compiled_document_name = "$name.ps";
            return ( 1, $error );    # Success!
        }
        else {
            return ( 0, $error );    # Failure
        }
    }
    else {                           # PDF mode
        if ( -e "$wd/$name.pdf" ) {
            $compiled_document      = "$wd/$name.pdf";
            $compiled_document_name = "$name.pdf";
            return ( 1, $error );    # Success!
        }
        else {
            return ( 0, $error );    # Failure
        }
    }
}

sub parse_log {
    my $error   = shift;
    my $logname = "$name.latexmk.log";

    if ($error) {

        # An error occurred during typesetting

        $typesetting_errors = 1;
        my $texparser_command = "texparser.py '$logname' "
          . "'$wd/$name' -notify $notification_token";
        my $output = `$texparser_command`;
        $output =~ /.*Notification\ Token:\ \|(\d+)\|/;
        $notification_token = $1;
    }
    elsif ( file_has_min_lines( "$logname", 4 ) ) {

        # The state has changed since last time and there are no errors. We
        # check for state changes by looking at the log. The log produced by
        # `latexmk` will be about 3 lines long if there were no changes in the
        # document. If there were any significant changes then the log should be
        # longer than that.

        $typesetting_errors = 0;
        close_notification_window();
        fail_unless_system( "texparser.py", "$logname", "$wd/$name" );

    }
    elsif ($typesetting_errors) {

        # We might have closed the notification window although there still
        # were errors. Lets reopen it if it was closed

        my $open_windows  = `"$DIALOG" nib --list`;
        my $window_closed = 1;

        for ( split /^/, $open_windows ) {
            debug_msg( "Line:", $_ );
            if (/^$notification_token/) {
                $window_closed = 0;
                last;
            }
        }

        if ($window_closed) {
            debug_msg(
                "Window $notification_token closed." . " Opening new window." );

            my $output = `texparser.py '$logname' '$wd/$name' -notify reload`;
            $output =~ /.*Notification\ Token:\ \|(\d+)\|/;
            $notification_token = $1;
        }

    }
}

sub close_notification_window {
    if ( $notification_token ne '' ) {
        fail_unless_system( "$DIALOG", "nib", "--dispose",
            "$notification_token" );
        $notification_token = '';
    }
}

#####################
# Viewer invocation #
#####################

my ( $start_viewer, $refresh_viewer, $viewer_id );

sub view {
    if ( defined($viewer_id) ) {
        $refresh_viewer->($viewer_id)
          if defined($refresh_viewer);
    }
    else {
        $viewer_id = $start_viewer->();
    }
}

####################
# Viewer selection #
####################

# # # # # # # # # # #
# PostScript Viewer #
# # # # # # # # # # #

my ( @ps_viewer, $hup_viewer );

sub select_postscript_viewer {

    # PostScript viewer: try to discover the right options to use with
    # whichever version of gv we find.
    $hup_viewer = 1;
    {
        my $gv_version = `gv --version 2>/dev/null`;
        if ( $? == -1 or $? & 127 ) {
            fail("Failed to execute gv ($?): $!");
        }
        elsif ($?) {

            # Assume that gv did not understand the --version option,
            # and that it is therefore a pre-3.6.0 version
            @ps_viewer = qw(gv -spartan -scale 1 -nocenter -antialias -nowatch);
        }
        elsif ( $gv_version =~ /^gv 3.6.0$/ ) {

            # This version is hopelessly broken. Give up.
            fail(
                "Broken GV detected",
                "You appear to have gv version 3.6.0. "
                  . "This version is hopelessly broken. I recommend you "
                  . "upgrade to 3.6.2, or (even better) downgrade to 3.5.8, "
                  . "which is currently the most stable version"
            );
        }
        elsif ( $gv_version =~ /^gv 3.6.1$/ ) {

            # Version 3.6.1 of GV has a bug that means it
            # dies if it receives a HUP signal. Therefore we execute it
            # in watch mode, and don't send a HUP.
            #
            # It also has a bug that means the --scale option causes it
            # not to open the specified document, and show a blank screen.
            @ps_viewer  = qw(gv --spartan --nocenter --antialias --watch);
            $hup_viewer = 0;
        }
        elsif ( $gv_version =~ /^gv 3.6.2$/ ) {

            # The --scale bug has still not been fixed in 3.6.2,
            # but the HUP one has.
            @ps_viewer = qw(gv --spartan --nocenter --antialias --nowatch);
        }
        else {
            # Hope for the best, with future versions!
            # (I have reported the bug, so with any luck it'll be fixed?)
            @ps_viewer =
              qw(gv --spartan --scale 1 --nocenter --antialias --nowatch);
        }
    }

    $start_viewer   = \&start_postscript_viewer;
    $refresh_viewer = \&refresh_postscript_viewer;
    $cleanup_viewer = \&cleanup_postscript_viewer;
    $ping_viewer    = \&ping_postscript_viewer;
    debug_msg( "PostScript viewer selected", @ps_viewer );
}

sub start_postscript_viewer {
    my $pid = fork();
    if ($pid) {

        # In parent
        return $pid;
    }
    else {
        # In child
        POSIX::setsid();    # detach from terminal
        close STDOUT;
        open( STDOUT, ">", "/dev/null" );
        close STDERR;
        open( STDERR, ">", "/dev/console" );

        debug_msg("Starting PostScript viewer ($$)");

        exec( @ps_viewer, $compiled_document )
          or fail( "Failed to start PostScript viewer",
            "I failed to run the PostScript viewer (@ps_viewer): $!" );
    }
}

sub refresh_postscript_viewer {
    if ($hup_viewer) {
        kill( 1, $viewer_id )
          or fail(
            "Failed to signal viewer",
            "I failed to signal the PostScript viewer (PID $viewer_id)"
              . " to reload: $!"
          );
    }
}

sub cleanup_postscript_viewer {
    kill( 2, $viewer_id ) if defined $viewer_id;
}

sub ping_postscript_viewer {
    if ( defined $viewer_id and waitpid( $viewer_id, POSIX::WNOHANG() ) ) {
        my $r = $?;
        if ( $r & 127 ) {
            fail( "Viewer failed",
                "The PostScript viewer died with signal " . ( $r & 127 ) );
        }
        elsif ( $r >>= 8 ) {
            fail( "Viewer failed",
                "The PostScript viewer exited with an error (error code $r)" );
        }
        return;    # Failed to ping
    }
    else {
        return 1;    # Pinged successfully
    }
}

# # # # # # # #
# PDF Viewer  #
# # # # # # # #

my $pdf_viewer_app;

sub select_pdf_viewer {
    my ($viewer) = @_;
    $viewer ||= "Skim";    # We use Skim as default viewer

    debug_msg("PDF Viewer selected ($viewer)");

    # These are the default, generic routines
    $start_viewer   = \&start_pdf_viewer;
    $ping_viewer    = \&ping_pdf_viewer;
    $cleanup_viewer = \&cleanup_pdf_viewer;
    $pdf_viewer_app = $viewer;

    if ( $viewer eq "TeXShop" ) {
        $start_viewer   = \&start_pdf_viewer_texshop;
        $refresh_viewer = \&refresh_pdf_viewer_texshop;
        $ping_viewer    = \&ping_pdf_viewer_texshop;
        $cleanup_viewer = \&cleanup_pdf_viewer_texshop;
    }
    elsif ( $viewer eq "Skim" ) {
        $refresh_viewer = \&refresh_pdf_viewer_skim;
    }

    return $viewer;
}

# TexShop

# We use open_for_externaleditor on the .tex file, rather than just opening the
# .pdf. In principle, either ought to work (hence the generic routines could be
# used for everything other than refresh) but at the time of writing the
# current version of TeXShop has a bug with the effect that, if certain
# encodings (e.g. UTF-8) are specified in the TeXShop preferences, opening a
# PDF file directly will trigger a spurious encoding warning. So this is a
# workaround.

sub start_pdf_viewer_texshop {
    debug_msg(
        "Starting PDF viewer (TeXShop) for file",
        "Opening file: $compiled_document"
    );
    applescript( qq(tell application "TeXShop" )
          . qq(to open_for_externaleditor at )
          . quote_applescript("$absolute_wd/$compiled_document_name") );
    $viewer_id = "TeXShop";
}

sub refresh_pdf_viewer_texshop {
    debug_msg("Refreshing PDF viewer (TeXShop)");
    applescript( qq(tell document )
          . quote_applescript("$compiled_document_name")
          . qq( of application "TeXShop" to refreshpdf) );
}

my $ping_failed;

sub ping_pdf_viewer_texshop {
    my $r = check_open( $pdf_viewer_app, "$compiled_document_name" );
    $ping_failed = 1 if !$r;
    return $r;
}

sub cleanup_pdf_viewer_texshop {
    return if $ping_failed;
    debug_msg("Closing document in PDF viewer ($pdf_viewer_app)");
    applescript_ignoring_errors( qq(tell application )
          . quote_applescript($pdf_viewer_app)
          . qq( to close document )
          . quote_applescript("$compiled_document_name") );
}

# Skim

sub refresh_pdf_viewer_skim {
    debug_msg("Refreshing PDF viewer (Skim)");

    # We ignore errors, because this is only supported in Skim 0.5 and later
    applescript_ignoring_errors( qq(tell application "Skim")
          . qq( to revert document )
          . quote_applescript("$name.pdf") );
}

# Generic routines that should work for any viewer

sub start_pdf_viewer {
    fail_unless_system( "open", "-a", $pdf_viewer_app, $compiled_document );
}

sub ping_pdf_viewer {
    my $r = check_open( $pdf_viewer_app, $compiled_document_name );
    $ping_failed = 1 if !$r;
    return $r;
}

sub cleanup_pdf_viewer {
    return if $ping_failed;
    debug_msg("Closing document in PDF viewer ($pdf_viewer_app)");
    applescript_ignoring_errors( qq(tell application )
          . quote_applescript($pdf_viewer_app)
          . qq( to close document )
          . quote_applescript($compiled_document_name) )
      if defined $compiled_document_name;
}

####################
# Utility routines #
####################

# Explain what's happening (if we're debugging)
sub debug_msg {
    print "Latex Watch INFO: @_\n" if $DEBUG;
}

my $CocoaDialog;

sub init_CocoaDialog {
    ($CocoaDialog) = @_;
}

# Display an error dialog and exit with exit-code 1
sub fail {
    my ( $message, $explanation ) = @_;
    system( $CocoaDialog, "msgbox",
        "--button1"          => "Cancel",
        "--title"            => "LaTeX Watch error",
        "--text"             => "Error: $message",
        "--informative-text" => "$explanation."
    );
    exit(1);
}

sub fail_unless_system {
    my $error_callback;
    if ( ref( $_[-1] ) eq 'CODE' ) {
        $error_callback = pop;
    }
    debug_msg( "Executing ", @_ );
    system(@_);
    if ( $? == -1 ) {
        fail( "Failed to execute $_[0]",
            "The command '@_' failed to execute: $!" );
    }
    elsif ( $? & 127 ) {
        fail(
            "Command failed",
            "The command '@_' caused $_[0] to die with signal " . ( $? & 127 )
        );
    }
    elsif ( $? >>= 8 ) {
        if ( defined $error_callback ) {
            $error_callback->(@_);
        }
        else {
            fail( "Command failed", "The command '@_' failed (error code $?)" );
        }
    }
}

# Put up a dialog box, and return the result
sub cocoa_dialog {
    pipe( my $rh, my $wh );
    if ( my $pid = fork() ) {

        # Parent
        local $/ = "\n";
        my $button = <$rh>;
        waitpid( $pid, 0 );
        if ($?) {

            # If we failed to show the dialog, there's not much sense
            # in trying to put up another dialog to explain what happened!
            # Print a message to the console.
            print "LaTeX Watch: Failed to display dialog box ($?): @_\n";
            debug_msg("Failed to display dialog box");
        }
        else {
            debug_msg("cocoa_dialog: Button $button");
            return $button;
        }
    }
    else {
        close(STDOUT);
        open( STDOUT, ">&", $wh );    # Talk to the pipe!

        # Enclose the exec command in a block, to avoid the warning about code
        # following exec.
        { exec( $CocoaDialog, @_ ) }

        # If there's an error, just exit with a non-zero code.
        debug_msg("Child process failed to offer to show log.");
        POSIX::_exit(2);    # Use _exit so we don't trigger cleanup code.
    }
}

sub applescript {

    # We could do this much more efficiently using Mac::OSA
    # but that's only preinstalled on 10.4 and later.
    fail_unless_system( "osascript", "-e", @_ );
}

sub applescript_ignoring_errors {
    debug_msg( "Applescript: ", @_ );
    system( "osascript", "-e", @_ );
}

sub quote_applescript {
    my ($str) = @_;
    $str =~ s/([\\\"])/\\$1/g;
    return qq("$str");
}

sub check_open {
    my $still_open = 1;
    fail_unless_system(
        "check_open",
        ( $DEBUG ? "-q" : "-s" ),
        @_,
        sub {
            fail("check_open failed. See console for details") if $? == 255;

            # If check_open can't tell, then we err on the side of caution.
            $still_open = 0 unless $? == 3;
        }
    );
    return $still_open;
}

sub file_has_min_lines {
    my $filepath         = shift;
    my $min_number_lines = shift;

    open( my $fh, "<", $filepath )
      or die "Can not open $filepath: $!";

    my $lines = 0;
    while (<$fh>) {
        last if ( $lines >= $min_number_lines );
        $lines++;
    }
    close($fh);

    return ( $lines >= $min_number_lines );
}

__END__

BUGS?
   - Spews too much information to the console

LIMITATIONS:
   - Cannot specify different modes per file.
   - Only works with latex, xelatex and lualatex not ConTeXt, etc.

FUTURE:
   - Support DVI route without GV, warning where appropriate.
     [If GV not installed, fall back to something else.]
   - Support xetex.
   - If TM_LATEX_VIEWER unset, sniff available viewers and pick one.
     (If it's set to "Preview", warn that Preview sucks and look for another.)
   - Nicer error output would be a really nice feature

Changes
1.1:
   - Include $! in error message if ps_viewer fails to start
   - run etex in batchmode
   - deal sensibly with compilation errors (don't just quit, offer to show log)
   - use 'gv -scale 1' (x 1.414) instead of '-scale 2' (x 2)

1.2:
   - Add Fink path (/sw/bin) to $PATH
   - Improved error handling in the command
   - don't assume this script is executable
   - work if perl is in PATH, even if it's not in /usr/bin

1.3:
   - Send errors to /dev/console rather than /tmp/out. (Thanks, Allan!)
   - Add default MacTeX location to PATH
   - support GV 3.6.[0-1], which has a different command-line syntax (!)
      (this is fixed in 3.6.2, but some users have 3.6.[01])
   - Move changelog to end of file
   - Handle preamble errors better
   - Take file path and switches on the command-line

1.4:
   - Set $/ in cocoa_dialog, or it won't work when called from reload().

1.5:
   - Add --debug-to-console option
   - Add --textmate-pid option
   - Throw an error if command-line options can't be parsed
   - Detect changes in files referenced by preamble
   - Detect changes in files referenced by body
   - Set $DISPLAY to ":0" if it isn't already set

2.0:
   - Add PDF support, using TeXShop as the viewer
   - Add TeXniscope support

2.1:
   - Add PDFView support: in fact, add rudimentary support for arbitrary
     viewer applications.
   - Don't attempt to close doc on cleanup, if we know it's already been closed.
   - Add -s switch to check_open, and pass it when not debugging.
   - Remove TM_LATEX_WATCH_VIEWER. Always use TM_LATEX_VIEWER instead.
   - Use TM_LATEX_PROGRAM to decide how to behave, instead of
     TM_LATEX_WATCH_MODE.

2.2:
   - Change button names on error dialog to 'Show Log' and 'Don't Show'.
   - Progress bar on initial compilation.
   - Add .pdf and .pdfsync to the list of files to clean up.
   - Don't skip dotfiles, so e.g. display will update if citation details
     change.
   - If in PDF mode, use pdfetex even for the format generation. This allows
     the graphics package (and other packages, potentially) to assume the
     correct mode.
   - Help file.
   - Support for the Skim previewer.
   - pdfsync synchronisation now works.
   - Include a copy of pdfsync in the bundle, because the LaTeX bundle
     has its own pdfsync, so users might be confused if it works with ⌘R
     but not with Watch. For the same reason, I have included the same
     version that the LaTeX bundle uses, rather than the latest version,
     since pdfsync 1.0 seems to conflict with more packages (e.g. diagrams).

2.3:
   - Rename the PDF file after generation, to prevent viewers from attempting
     to reload it when it's partially generated.
   - As a side-effect of the above, two-way syncing now works with Skim!
   - Improve change detection logic, so that changes made during compilation
     are not ignored.
   - Fix recently-introduced bug that caused incorrect watcher_pid to be
     recorded.

2.4:
   - Warn if PostScript mode is used with a non-default previewer.
   - Expand the help file a little.
   - With TeXShop, use open_for_externaleditor on the .tex file, to work
     around an encoding-related bug in TeXShop.
   - Add a refresh command for Skim, which works in Skim 0.5 and later.
     This is just as well, since the automatic file-change checking is broken
     in Skim 0.5!

2.5:
   - Delete .watcher_pid file on exit. (I think this was broken by 2.3.)
   - Fix bug introduced in 2.4 that broke TeXShop updating.
   - Use a sanitised name for the .foo.* files, because format names containing
     spaces don't seem to work (so we would fail for filenames with spaces in).
   - Change into the working directory, rather than using the full path, to
     avoid problems caused by special characters in the name of some ancestor
     directory.
   - Quote Applescript strings, so that filenames containing special characters
     (backslash and double quote) will not cause Applescript errors. (They do
     still cause problems with PDFSync in Skim: see
     http://sourceforge.net/p/skim-app/bugs/72/)
   - Catch the obscure case where the filename ends in ".tex\n", which
     would previously cause mysterious-looking problems.
   - Remove the 'hide extension' attribute on the .tex file, if TeXShop is
     used as the viewer, otherwise updating will fail for interesting reasons
     that I won't go into here.

2.6:
    - Suppress warnings when no viewer is explicitly selected; make sure the
      'hide extension' attribute is removed in that case too.
   - Integrate with Brad's new version of the LaTeX bundle: use the new prefs
     system.

2.7:
   - Fix TeXniscope support.
   - Deal more robustly with files that are written as well as read during
     processing (previously this could cause an infinite update loop)

2.8:
   - Locate '\begin{document}' in a more flexible way.
   - If an input file disappears, remove it from the watch list (otherwise it
     will recompiling the document in an endless loop).

2.9:
   - The loop-prevention code added in 2.7 did not work correctly in the case
     where a file is read from the preamble and written from the document body.
     This arises when the svn-multi package is used, for example. It should now
     work correctly.

3.0:
   - Use `latexmk` to translate documents. This change allows us to directly
   translate the whole document without the need to use any of the common
   external TeX tools (`bibtex`, `makeindex`, …) directly.
   - Add support for `%!TEX TS-program`. We now try to read the typesetting
   program specified in the tex file. If the typesetting program is not
   specified inside the file then we use the engine specified in the settings
   dialog.

3.1:
    - Fix support for “TeXShop” PDF viewer.

3.2:
    - Update the list of auxiliary files removed on cleanup.

3.3:
    - (Re)add support for SyncTeX.

3.4:
    - Remove support for teTeX

3.5:
    - Remove support for TeXniscope

3.6:
    - Support engine options

      Add support for options like `--shell-escape`. You can specify these
      options inside the preferences of the LaTeX bundle. (Nemesit Amasis)

3.7:
    - Use the bundles `latexmkrc` file

3.8:
    - We now display a notification window in the case of an error. The window
    displays all errors containing line information that `texparser` finds in
    the log output of `latexmk`.

3.9:
    - Update the list of auxiliary files removed on cleanup.

3.10:
    - Remove temporary dir created by `pythontex` on cleanup.

3.11:
    - Remove temporary dir created by package `minted` on cleanup.

3.12:
    - Do not extend the environment variable TEXINPUTS any more. We used to do
      this to support “pdfsync”. New TeX distributions include support for the
      “pdfsync” replacement “SyncTeX”. This means we do not need to support
      “pdfsync” any more.

3.13:
    - The script now reads the config file `auxiliary.yaml` to determine which
      files it removes on cleanup.

3.14:
    - Improve support for the minted package. Previously the script would
      sometimes refresh the viewer infinitely often, even if there were no
      changes to the watched document.

3.141:
    - Add new path for TeX binaries (MacTeX 2015, OS X 10.11). The script
      uses this value as backup, if we do not invoke it via “Watch Document”.

3.1415:
    - Use `clean.rb` to remove auxiliary files

3.14159:
    - The command now also removes the bundle cache file (`.filename.lb`)
      again, after we close the preview program.
