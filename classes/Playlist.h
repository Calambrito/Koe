#ifndef PLAYLIST_H
#define PLAYLIST_H

#include <string>
#include <list>
#include "Song.h"

class Playlist {
public:
    std::string name;
    std::list<Song> songs;

    Playlist(const std::string& name);

    void addSong(const Song& song);
    void removeSong(const std::string& songName);
};

#endif // PLAYLIST_H
