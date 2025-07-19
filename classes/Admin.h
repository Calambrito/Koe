#ifndef ADMIN_H
#define ADMIN_H

#include "User.h"
#include "Song.h"

class Admin : public User {
public:
    Admin(const std::string& username, Theme theme);

    void addSongToDatabase(const Song& song);
    void removeSongFromDatabase(const std::string& songName);
};

#endif // ADMIN_H
