#!/usr/bin/env perl

# Copyright 2015 Martijn Brekhof
#
# This file is part of dummymediafiles.
#
# dummymediafiles is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# dummymediafiles is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with dummymediafiles.  If not, see <http://www.gnu.org/licenses/>.
#
# The file holding the movie data should contain a line for each movie according to the following format:
#
#    "<TITLE>" (YEAR)     YEAR
#
# For each movie a file is created. For example:
#
#     The Matrix (1999)   1999   
# 
# will result in the following file:
#
#    The Matrix (1999).mp4
#

use strict;
use warnings;
use File::Copy qw(copy);

my $DATAFILE = shift;
my $AMOUNT = shift;
if ( ! defined( $AMOUNT ) ) {
	print "Usage: $0 <MP4FILE> <AMOUNT> < <INPUTFILE>\n";
	exit 1;
}


my $tmpfile = ".movies";


open(FH,">${tmpfile}");

my $linecnt = 0;

while(<>) {
	my ($title, $year) = $_ =~ /
	^(.*)\s+
	\(([0-9?]{4}).*\)\s+
	[0-9]+$
	/x;
	if( ( defined $title ) ) {
		$title =~ s/\s+$//;
		$title =~ s/\//_/g;
		my $file = "${title}";
		if( defined $year ) {
			$file = $file . " ($year)";
		}
		${file} = ${file} . ".mp4";
		print FH $file, "\n";		
		$linecnt++;
	} 
}

close FH;

if ( $AMOUNT > $linecnt ) {
	$AMOUNT = $linecnt;
}

# Randomly select up to $AMOUNT items from the INPUT
my %seen;
for (1..$AMOUNT) {
    my $candidate = int rand($linecnt);
    redo if $seen{$candidate}++;
}

open(FH,"${tmpfile}");
$linecnt = 0;
while(<FH>) {
	$linecnt++;
	next if ! defined( $seen{$linecnt} );
 
	chomp;
	my $file = $_;
	copy("$DATAFILE", "$file");
}
close FH;

#unlink $tmpfile || die "Failed to remove $tmpfile\n";
