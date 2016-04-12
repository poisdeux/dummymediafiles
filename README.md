# dummymediafiles
Scripts to setup empty music and video files to be used to test media centers

# Run

To create media files for music, tv shows, movies, and music videos run the following:

    make

If you only want to create media files for a specific type use one or more of the following `make` commands:

    make music
    make tvshows
    make movies
    make musicmovies

This will create a subdirectory `media` with all media files.


# Music data

The project includes a part of the [freedb](http://www.freedb.org) database. If you want to create music files using
the complete database you can download it using:

    make download-musicdata

This will setup the database under `data/freedb` and add/overwrite the database files included in the project.
After the download has completed you should run `make music` to create the actual media files.
