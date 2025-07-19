#ifndef LISTENER_H
#define LISTENER_H

#include <list>
#include <vector>
#include <string>
#include "User.h"
#include "Playlist.h"

class Listener : public User {
public:
    std::list<Playlist> playlists;
    std::vector<std::string> notifications;

    Listener(const std::string& username, Theme theme);

    void createPlaylist(const std::string& playlistName);
    void deletePlaylist(const std::string& playlistName);
};

#endif // LISTENER_H
