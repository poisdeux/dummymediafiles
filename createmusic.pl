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
	$id3v2->add_frame("TPE1", $artist) if defined $artist;     
	$id3v2->add_frame("TPE2", $artist) if defined $artist;     
	$id3v2->add_frame("TALB", $album) if defined $album;      
	$id3v2->add_frame("TIT2", $tracktitle) if defined $tracktitle; 
	$id3v2->add_frame("TRCK", $tracknumber) if defined $tracknumber;
	$id3v2->add_frame("TCON", $genre) if defined $genre;
	$id3v2->add_frame("TYER", $year) if defined $year;
	$id3v2->write_tag();
	$mp3->close();
}

sub createMusicFile($$$) {
	my $artist = shift;
	my $album = shift;
	my $filename = shift;
	
	print "Creating $artist/$album/$filename\n";			

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

# Setup corner cases
my $file = createMusicFile("The Artist", "unknown", "01-the_artist_no_album");
writeID3v2Tag(${file}, "The Artist", undef, undef, "Unknown", undef, undef);

$file = createMusicFile("unknown", "The Album", "01-the_album_no_artist");
writeID3v2Tag(${file}, undef, "The Album", undef, "Unknown", undef, undef);

$file = createMusicFile("unknown", "unknown", "01-the_title_no_artist_no_album");
writeID3v2Tag(${file}, undef, undef, undef, "The Title", undef, undef);

$file = createMusicFile("unknown", "unknown", "01-no_title_no_artist_no_album");
writeID3v2Tag(${file}, undef, undef, undef, undef, undef, undef);
