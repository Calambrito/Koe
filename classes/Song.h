#ifndef SONG_H
#define SONG_H

#include <string>

class Song {
public:
    std::string name;
    std::string url;
    float duration;
    bool loop;

    Song(const std::string& name, const std::string& url, float duration, bool loop);

    void play();
};

#endif // SONG_H
