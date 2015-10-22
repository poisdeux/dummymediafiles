# dummymediafiles
Scripts to setup empty music and video files to be used to test media centers

# Run

To create the directory structure and files for TV shows execute the following:

    ./createtvshows.pl < tvshows.txt

The file `tvshows.txt` should contain a line for each episode according to the following format:

    "<TITLE>" (YEAR) {<EPISODETITLE> (#<SEASONNUMBER>.<EPISODENUMBER>)}


For each TV show a directory is created and for each season a subdirectory. Each
season directory will contain empty files using the format `S<SEASONNUMBER>E<EPISODENUMBER>.mp4`
For example episode 2 of season 1 of "Breaking Bad" should look as follows in the text file:

    "Breaking Bad" (2008) {4 Days Out (#2.9)}               2009
 
and will result in the following directory structure:

    Breaking Bad (2008)
    `-- Season 2
        `-- S2E9.mp4


