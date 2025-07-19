#ifndef ARTIST_H
#define ARTIST_H

#include <list>
#include "Listener.h"

class Artist {
public:
    std::list<Listener*> subscribers;

    void notify(const std::string& message);
};

#endif // ARTIST_H
