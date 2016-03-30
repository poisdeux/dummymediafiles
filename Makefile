all: music tvshows movies musicvideos

music:
	mkdir -p media/music
	cd media/music && ../../createmusic.pl ../../data/silence_5sec.mp3 ../../data/freedb-partial/*

tvshows:
	mkdir -p media/tvshows
	cd media/tvshows && gunzip -c ../../data/movies.list.gz | ../../createtvshows.pl ../../data/blank.mp4 500
	
movies:
	mkdir -p media/movies
	cd media/movies && gunzip -c ../../data/movies.list.gz | ../../createmovies.pl 1000

musicvideos:
	mkdir -p media/musicvideos
	cd media/musicvideos && cat ../../data/musicvideos.list | ../../createmusicvideos.pl ../../data/blank.mp4

clean:
	rm -rf media

clean-music:
	rm -rf media/music

clean-tvshows:
	rm -rf media/tvshows

clean-musicvideos:
	rm -rf media/musicvideos
