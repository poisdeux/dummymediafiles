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
use File::Copy qw(copy);
 
if (@ARGV < 2) {
    print "Usage: createmusic.pl <MP3FILE> <DIR>...\n";
    exit;
}

my $MP3FILE = shift @ARGV;

sub trim($) {
	my $s = shift; 
	$s =~ s/^\s+|\s+$//g; 
	return $s;
}

sub writeID3v2Tag($$$$$$$) {
	my $filename = shift;
	my $artist = shift;
	my $album = shift;
	my $tracknumber = shift;
	my $tracktitle = shift;
	my $year = shift;
	my $genre = shift;

	my $mp3 = MP3::Tag->new($filename);
	my $id3v2 = $mp3->new_tag("ID3v2");
	$id3v2->add_frame("TPE1", $artist);     
	$id3v2->add_frame("TPE2", $artist);     
	$id3v2->add_frame("TALB", $album);      
	$id3v2->add_frame("TIT2", $tracktitle); 
	$id3v2->add_frame("TRCK", $tracknumber);
	$id3v2->add_frame("TCON", $genre);
	if( defined $year) {    
		$id3v2->add_frame("TYER", $year);
	}       
	$id3v2->write_tag();
	$mp3->close();
}

sub writeID3Tag($$$$$$$) {
	my $filename = shift;
	my $artist = shift;
	my $album = shift;
	my $tracknumber = shift;
	my $tracktitle = shift;
	my $year = shift;
	my $genre = shift;

	my $mp3 = MP3::Tag->new($filename);
  	my $id3v1 = $mp3->new_tag("ID3v1");

	$id3v1->artist($artist);
	$id3v1->album($album);
	$id3v1->title($tracktitle);
	$id3v1->track($tracknumber);
	$id3v1->genre($genre);
	$id3v1->year($year);

	$id3v1->write_tag();
	$mp3->close();
}

sub createMusicFile($$$) {
	my $artist = shift;
	my $album = shift;
	my $filename = shift;
	
	if( ! -e "${artist}" ) {
		mkdir "${artist}" or die "Error: failed to create directory ${artist}";
	}
	
	if ( ! -e "${artist}/${album}" ) {
		mkdir "${artist}/${album}" or die "Error: failed to create directory ${artist}/${album}";
	}
	
	my $file= "${artist}/${album}/${filename}.mp3";

	# Create an empty file	
	copy("$MP3FILE", "${file}") or return undef;

	return $file;
}

sub parseFreedbFile($) {
	my $filename=$_[0];
	my $artist;
	my $album;
	my $year;
	my $genre;
	open FH, $filename or die "Error opening file $filename\n";
	while(<FH>) {
		if ( /^DYEAR=([0-9]+)/ ) {
			$year = trim $1;
		} elsif ( /^DGENRE=(.+)/ ) {
			$genre = trim $1;
		} elsif ( /^DTITLE=(.*)\s\/\s(.*)$/ ) {
			$artist = trim $1;
			$album = trim $2;
			$album =~ s/\//-/;
		} elsif ( $_ =~ /^TTITLE(\d+)=(.*)$/ ) {
			my $trackno = trim $1;
			my $tracktitle = trim $2;
			if( $trackno < 10 ) {
				$trackno = "0$trackno";
			}
			my $file = $trackno;
			my $trackartist;
			my $trackname;
			if ( $tracktitle =~ /\// ) {
				$tracktitle =~ /(.*)\/(.*)/;
				$trackartist = trim $1;
				$trackname = trim $2;
				$file = $file . "-$trackartist-$trackname";
			} else {
				$file = $file . "-$tracktitle";
			}
			
			$file = createMusicFile($artist, $album, $file);				

			if( defined($file) ) {
				if( defined $trackartist ) {
					writeID3v2Tag(${file}, ${trackartist}, ${album}, ${trackno}, ${trackname}, ${year}, ${genre});
				} else {
					writeID3v2Tag(${file}, ${artist}, ${album}, ${trackno}, ${tracktitle}, ${year}, ${genre});
				}
					
			}
		}
	}
}

foreach my $DIR (@ARGV) {

	opendir DH, $DIR or die "Error opening dir $DIR\n";

	while(my $filename = readdir(DH)) {
		my $file = "${DIR}/${filename}";
		if( -f $file ) {
			parseFreedbFile($file);
		}
	}
}
