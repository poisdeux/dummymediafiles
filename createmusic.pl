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

if (@ARGV == 0) {
    print "Usage: createmusic.pl <DIR>...\n";
    exit;
}

sub parseFile($) {
	my $filename=$_[0];
	my $artist;
	my $album;
	open FH, $filename or die "Error opening file $filename\n";
	while(<FH>) {
		if ( /^DTITLE=(.*)\s\/\s(.*)$/ ) {
			$artist=$1;
			$album=$2;
			$album =~ s/\//-/;
			if( ! -e "${artist}" ) {
				mkdir "${artist}" or die "Error: failed to create directory ${artist}";
			}
			if ( ! -e "${artist}/${album}" ) {
				mkdir "${artist}/${album}" or die "Error: failed to create directory ${artist}/${album}";
			}
		}

		if( my ($trackno, $tracktitle) = $_ =~ /^TTITLE(\d+)=(.*)$/ ) {
			if( $trackno < 10 ) {
				$trackno = "0$trackno";
			}
			my $file = $trackno;
			if ( $tracktitle =~ /\// ) {
				my ($trackartist, $trackname) = $tracktitle =~ /(.*)\s*\/\s*(.*)/;
				$file = $file . "-$trackartist-$trackname";
			} else {
				$file = $file . "$tracktitle";
			}
			$file= $file . ".mp3";
			if ( open(FW,">${artist}/${album}/${file}") ) {
				print FW "";
				close FW;
			}
		}
	}
}

foreach my $DIR (@ARGV) {

	opendir DH, $DIR or die "Error opening dir $DIR\n";

	while(my $filename = readdir(DH)) {
		my $file = "${DIR}/${filename}";
		if( -f $file ) {
			print "TEST $file\n";
			parseFile($file);
		}
	}
}
