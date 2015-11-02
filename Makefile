tvshows:
	mkdir -p media/tvshows
	cd media/tvshows && gunzip -c ../../data/movies.list.gz | ../../createtvshows.pl 
	
movies:
	mkdir -p media/movies
	cd media/movies && gunzip -c ../../data/movies.list.gz | ../../createmovies.pl 
