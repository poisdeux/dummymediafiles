music:
	mkdir -p media/music
	cd media/music && ../../createmusic.pl ../../data/freedb-partial/*

tvshows:
	mkdir -p media/tvshows
	cd media/tvshows && gunzip -c ../../data/movies.list.gz | ../../createtvshows.pl 
	
movies:
	mkdir -p media/movies
	cd media/movies && gunzip -c ../../data/movies.list.gz | ../../createmovies.pl 

clean:
	rm -rf media
