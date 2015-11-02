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
use Cwd;
use MP3::Tag;

if (@ARGV == 0) {
    print "Usage: createmusic.pl <DIR>...\n";
    exit;
}

sub writeid3v2tag($$$$$$) {
	my $filename = shift;
	my $artist = shift;
	my $album = shift;
	my $tracknumber = shift;
	my $tracktitle = shift;
	my $year = shift;

	my $mp3 = MP3::Tag->new($filename);
  	my $id3v2 = $mp3->new_tag("ID3v2");
	$id3v2->add_frame("TOPE", $artist);	
	$id3v2->add_frame("TPE1", $artist);	
	$id3v2->add_frame("TALB", $album);	
	$id3v2->add_frame("TIT2", $tracktitle);	
	$id3v2->add_frame("TRCK", $tracknumber);
	if( defined $year) {	
		$id3v2->add_frame("TYER", $year);
	}	
	$id3v2->write_tag();
}

sub parseFile($) {
	my $filename=$_[0];
	my $artist;
	my $album;
	my $year;
	open FH, $filename or die "Error opening file $filename\n";
	while(<FH>) {
		if ( /^DYEAR=([0-9]+)/ ) {
			$year=$1;
		} elsif ( /^DTITLE=(.*)\s\/\s(.*)$/ ) {
			$artist=$1;
			$album=$2;
			$album =~ s/\//-/;
			if( ! -e "${artist}" ) {
				mkdir "${artist}" or die "Error: failed to create directory ${artist}";
			}
			if ( ! -e "${artist}/${album}" ) {
				mkdir "${artist}/${album}" or die "Error: failed to create directory ${artist}/${album}";
			}
		} elsif( my ($trackno, $tracktitle) = $_ =~ /^TTITLE(\d+)=(.*)$/ ) {
			if( $trackno < 10 ) {
				$trackno = "0$trackno";
			}
			my $file = $trackno;
			my $trackartist;
			my $trackname;
			if ( $tracktitle =~ /\// ) {
				($trackartist, $trackname) = $tracktitle =~ /(.*)\s*\/\s*(.*)/;
				$file = $file . "-$trackartist-$trackname";
			} else {
				$file = $file . "-$tracktitle";
			}
			$file= "${artist}/${album}/${file}.mp3";
			if ( open(FW,">${file}") ) {
				print FW "";
				close FW;

				my $tmpartist;
				if( defined $trackartist ) {
					$tmpartist = $trackartist;
				} else {
					$tmpartist = $artist;
				}
				writeid3v2tag(${file}, ${tmpartist}, ${album}, ${trackno}, ${tracktitle}, ${year});
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
