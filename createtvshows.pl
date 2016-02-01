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
#
#
# The file holding the tv show data should contain a line for each episode according to the following format:
#
#    "<TITLE>" (YEAR) {<EPISODETITLE> (#<SEASONNUMBER>.<EPISODENUMBER>)}
#
# For each TV show a directory is created and for each season a subdirectory. Each
# season directory will contain empty files using the format `S<SEASONNUMBER>E<EPISODENUMBER>.mp4`
# For example episode 2 of season 1 of "Breaking Bad" should look as follows in the text file:
#
#     "Breaking Bad" (2008) {4 Days Out (#2.9)}               2009
#  
# and will result in the following directory structure:
# 
#    Breaking Bad (2008)
#    `-- Season 2
#        `-- S2E9.mp4
#

use strict;
use warnings;
use File::Copy qw(copy);

if (@ARGV < 2) {
    print "Usage: createtvshows.pl <VIDEOFILE> <AMOUNT>\n";
    exit;
}

my $DATAFILE = shift;
if (! -e "${DATAFILE}") {
	print "Error: ${DATAFILE} does not exist";
	exit 1;
}

my $amount = shift;

sub createFile($$$) {
	my $maingroup = shift;
	my $subgroup = shift;
	my $filename = shift;
	
	if( ! -e "${maingroup}" ) {
		mkdir "${maingroup}" or die "Error: failed to create directory ${maingroup}";
	}
	
	if ( ! -e "${maingroup}/${subgroup}" ) {
		mkdir "${maingroup}/${subgroup}" or die "Error: failed to create directory ${maingroup}/${subgroup}";
	}
	
	my $file= "${maingroup}/${subgroup}/${filename}";

	# Create an empty file	
	copy("$DATAFILE", "${file}") or return undef;

	return $file;
}

my %tvshows;

while(<>) {
	my ($title, $year, $eptitle, $season, $epnumber) = $_ =~ /
	\"(.*)\"\s+
	\(([0-9]*).*\)\s+
	\{(.*)\s*
	\(\#([0-9]+)
	\.([0-9]+)\)\}
	.*
	/x;
	if( ( defined $title ) && ( defined $season ) && ( defined $epnumber ) ) {
		$title =~ s/\s+$//;
		$title =~ s/\//_/g;
		if( defined $year ) {
			$title = $title . " ($year)";
		}
		if ( ! exists ( $tvshows{$title} ) ) {
			$tvshows{$title} = {};
		}
		
		if ( ! exists ( $tvshows{$title}{$season} ) ) {
			$tvshows{$title}{$season} = {};
		}
		
		$tvshows{$title}{$season}{$epnumber} = 1;

	} 
}

my @titles = keys %tvshows;

#Randomly select $amount tvshows
my %seen;
if ( $amount < @titles ) {
	for (1..$amount) {
    		my $index = int rand(@titles);
    		redo if $seen{$titles[$index]}++;
	}
} else {
	%seen = %tvshows;	
}

foreach my $title (keys %seen) {
	my %seasons = %{$tvshows{$title}};
	foreach my $seasontitle (keys %seasons ) {
		my %season = %{$seasons{$seasontitle}};	
		foreach my $episode (keys %season) {
			createFile(${title}, "Season ${seasontitle}", "S${seasontitle}E${episode}.mp4");
		}
	}
}
