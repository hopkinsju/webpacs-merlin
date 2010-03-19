#!/usr/local/bin/perl -w
#
# configure
#
# This script determines the correct root directory
# for the project (the parent of the 'bin' directory
# in which it is located), prompts for some configuration
# values if not set via command-line options, and then
# calls ttree to process all files under the skeleton
# directory, storing output relative to the project root
# directory (e.g., skeleton/bin/build => bin/build).
#
# Copyright 2003 Andy Wardley.
#
# This is free software distributed under the same terms as Perl.
#

use strict;
use warnings;
use FindBin qw( $Bin );
use Getopt::Std;
local $|=1;

# defaults
my $URL  = '/screens';
my $INI  = 'anonymous';

# get options
our ($opt_d, $opt_u, $opt_y, $opt_h, $opt_i);
getopts('yhdui:');

# display usage and exit on -h
die <<END_USAGE if $opt_h;
usage: configure [options]

options:
    -u url    url for HTML pages  (default: $URL)
    -d debug  set debug flag      (default: 0)
    -y        Accept defaults
    -i        your initials
    -h        This help
END_USAGE

# work out where we are in the filesystem
my @dirs = File::Spec->splitdir($Bin);
pop @dirs;  # remove 'bin'
my $dir  = File::Spec->catdir(@dirs);
my $skel = File::Spec->catfile($dir, 'skeleton');
my $cfg  = File::Spec->catfile($dir, 'etc/configure.cfg');

#$dir =~ ,\,\\,;

# prompt for root URL
my $url  = prompt('root page URL', $opt_u || $URL);
my $initials  = prompt('your initials', $opt_i || $INI);
my $dbg  = prompt('enable debugging?', $opt_d ? 'yes' : 'no')
         =~ /^y(es)?/ ? 1 : 0;

$dir  = qq("$dir");
$skel = qq("$skel");
$url  = qq("$url");
$cfg  = qq("$cfg");

# hand over to ttree
my @args = ( 'ttree',
             '-f', $cfg,
             '-s', $skel,
             '-d', $dir,
             '--define', "dir=$dir",
             '--define', "url=$url",
             '--define', "debug=$dbg",
             '--define', "initials=$initials",
             @ARGV );

print "@args\n";

system(@args) == 0
    or die "ttree failed: $?\n";

#------------------------------------------------------------------------
# prompt($message, $default)
#
# Prompt user to input value or accept default.
#------------------------------------------------------------------------

sub prompt {
    my ($msg, $def) = @_;
    my $ans = '';
    $def = '' unless defined $def;

    print "$msg [$def] ";

    if ($opt_y) {    # accept default
        print "$def\n";
    }
    else {           # read user input
        chomp($ans = <STDIN>);
    }

    return length($ans) ? $ans : $def;
}

exit 0
