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

sub writeID3v2Tag($$$$$$$$) {
	my $filename = shift;
	my $artist = shift;
	my $album = shift;
	my $albumartist = shift;
	my $tracknumber = shift;
	my $tracktitle = shift;
	my $year = shift;
	my $genre = shift;

	my $mp3 = MP3::Tag->new($filename);

	my $id3v2 = $mp3->new_tag("ID3v2");
	$id3v2->add_frame("TPE1", $artist) if defined $artist;     
	$id3v2->add_frame("TPE2", $albumartist) if defined $albumartist;
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
			my $trackartist = $artist;
			my $trackname = $tracktitle;
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
				writeID3v2Tag(${file}, ${trackartist}, ${album}, ${artist}, ${trackno}, ${trackname}, ${year}, ${genre});
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

## Artist, no album, no title
my $file = createMusicFile("The Artist", "unknown", "01-the_artist_no_album");
writeID3v2Tag(${file}, "The Artist", undef, undef, undef, "Unknown", undef, undef);

## No artist with album, no title
$file = createMusicFile("unknown", "The Album", "01-the_album_no_artist");
writeID3v2Tag(${file}, undef, "The Album", undef, undef, "Unknown", undef, undef);

## No artist, no album, with title
$file = createMusicFile("unknown", "unknown", "01-the_title_no_artist_no_album");
writeID3v2Tag(${file}, undef, undef, undef, undef, "The Title", undef, undef);

## No artist, no album, no title
$file = createMusicFile("unknown", "unknown", "01-no_title_no_artist_no_album");
writeID3v2Tag(${file}, undef, undef, undef, undef, undef, undef, undef);

# Song with three artists
$file = createMusicFile("ThreeArtists", "ThreeArtistsAlbum", "01-threeartists");
writeID3v2Tag(${file}, "First artist\0Second artist\0Third artist", "ThreeArtistsAlbum", "First artist\0Second artist\0Third artist", 01, "threeartists", undef, undef);

# Various artists album
$file = createMusicFile("Various Artists", "Various Artists Album", "01-first_artist");
writeID3v2Tag(${file}, "First artist", "Various Artists Album", "Various Artists", 01, "first song", undef, undef);
$file = createMusicFile("Various Artists", "Various Artists Album", "02-second_artist");
writeID3v2Tag(${file}, "Second artist", "Various Artists Album", "Various Artists", 02, "second song", undef, undef);
$file = createMusicFile("Various Artists", "Various Artists Album", "03-third_artist");
writeID3v2Tag(${file}, "Third artist", "Various Artists Album", "Various Artists", 03, "third song", undef, undef);

# Various artists album, no album artist
$file = createMusicFile("unknown", "Various Artists Album No Album Artist", "01-first_artist_no_album_artist");
writeID3v2Tag(${file}, "First artist", "Various Artists Album No Album Artist", undef, 01, "first song no album artist", undef, undef);
$file = createMusicFile("unknown", "Various Artists Album No Album Artist", "02-second_artist_no_album_artist");
writeID3v2Tag(${file}, "Second artist", "Various Artists Album No Album Artist", undef, 02, "second song no album artist", undef, undef);
$file = createMusicFile("unknown", "Various Artists Album No Album Artist", "03-third_artist_no_album_artist");
writeID3v2Tag(${file}, "Third artist", "Various Artists Album No Album Artist", undef, 03, "third song no album artist", undef, undef);

# Various artists album, no song artist, with album artist 
$file = createMusicFile("unknown", "Various Artists Album with Album Artist but no Artist", "01-first_album_artist_no_song_artist");
writeID3v2Tag(${file}, undef, "Various Artists Album No Song Artist", "Various Artists", 01, "first song album artist no song artist", undef, undef);
$file = createMusicFile("unknown", "Various Artists Album with Album Artist but no Artist", "02-second_album_artist_no_song_artist");
writeID3v2Tag(${file}, undef, "Various Artists Album No Song Artist", "Various Artists", 02, "second song album artist no song artist", undef, undef);
$file = createMusicFile("unknown", "Various Artists Album with Album Artist but no Artist", "03-third_album_artist_no_song_artist");
writeID3v2Tag(${file}, undef, "Various Artists Album No Song Artist", "Various Artists", 03, "third song album artist no song artist", undef, undef);

