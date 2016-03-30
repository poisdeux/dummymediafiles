#!/usr/bin/perl

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

use strict;
use warnings;

use strict;
use warnings;
use File::Copy qw(copy);
 
if (@ARGV < 1) {
    print "Usage: createmusicvideos.pl <MP3FILE> < <INPUTFILE>\n";
    exit;
}

my $DATAFILE= shift @ARGV;

sub trim($) {
	my $s = shift; 
	$s =~ s/^\s+|\s+$//g; 
	return $s;
}
 sub createFile($) {
	my $filename = shift;
	
	# Create an empty file	
	copy("$DATAFILE", "${filename}") or return undef;
}

while(<>) {
	chomp;
	my $file = $_ . ".mp4";
	createFile($file);
}


