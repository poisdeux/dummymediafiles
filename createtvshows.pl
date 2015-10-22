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
		my $dir = "${title}";
		if( defined $year ) {
			$dir = $dir . " ($year)";
		}
		my $seasondir = "${dir}/Season ${season}";
		my $file = "$seasondir/S${season}E${epnumber}.mp4";
		if ( ! -e ${dir} ) { 
			mkdir "${dir}" or die "Line: $_ failed: $!: ${dir}";
		}
		if ( ! -e ${seasondir} ) {
			mkdir "${seasondir}" or die "Line: $_ failed: $!: ${seasondir}";
		}
		open(FW,">${file}");
		print FW "";
		close FW;
	} 
}
