#!/usr/bin/perl

# -- Imports -------------------------------------------------------------------

use strict;
use warnings;

use Cwd qw(abs_path);
use File::Basename;
use Test::More tests => 8;

use lib dirname( dirname( dirname abs_path $0) ) . '/Support/lib/Perl';
use Latex qw(guess_tex_engine master tex_directives);

# -- Tests ---------------------------------------------------------------------

my $tex_dir = dirname( dirname abs_path $0) . '/TeX';
my ( %reference, %output, $error, $output, $regex );

ok( guess_tex_engine( $tex_dir . '/xelatex.tex' ) eq 'xelatex',
    'Guess tex engine for xelatex.tex' );
ok( guess_tex_engine( $tex_dir . '/ünicöde.tex' ) eq 'xelatex',
    'Guess tex engine for ünicöde.tex' );
ok( guess_tex_engine( $tex_dir . '/text.tex' ) eq '',
    'Guess tex engine for text.tex' );

%reference = (
    'encoding'   => 'UTF-8 Unicode',
    'program'    => 'xelatex',
    'spellcheck' => 'en-US'
);
%output = tex_directives( $tex_dir . '/xelatex.tex' );

is_deeply( \%reference, \%output, 'Check tex directives for file xelatex.tex' );

%reference = ( 'root' => './packages_input2.tex' );
%output = tex_directives( $tex_dir . '/input/packages_input1.tex' );

is_deeply( \%reference, \%output,
    'Check tex directives for file packages_input1.tex' );

( $error, $output ) = master( $tex_dir . '/input/packages_input1.tex' );

ok(
    !$error && $output =~ m/TeX\/packages\.tex$/x,
    'Get master file for packages_input1.tex'
);

( $error, $output ) = master( $tex_dir . '/root loop.tex' );

ok( $error && $output =~ m/root\ loop\.tex\ was\ specified\ twice/x,
    'Detect the %!TEX root loop in root loop.tex' );

( $error, $output ) = master( $tex_dir . '/non existent root.tex' );

$regex = 'I\ do\ not\ exist.tex .* in .*'
  . 'non\ existent\ root\.tex\ can\ not\ be\ opened';

ok( $error && $output =~ qr/$regex/x,
    'Detect the non existent %!TEX root in non existent root.tex' );
