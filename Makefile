all: music tvshows movies

music:
	mkdir -p media/music
	cd media/music && ../../createmusic.pl ../../data/freedb-partial/*

tvshows:
	mkdir -p media/tvshows
	cd media/tvshows && gunzip -c ../../data/movies.list.gz | ../../createtvshows.pl 500
	
movies:
	mkdir -p media/movies
	cd media/movies && gunzip -c ../../data/movies.list.gz | ../../createmovies.pl 1000

musicvideos:
	mkdir -p media/musicvideos
	cd media/musicvideos && cat ../../data/musicvideos.list | ../../createmusicvideos.pl

clean:
	rm -rf media
