#ifndef FILTER_H
#define FILTER_H

#include <vector>
#include "Song.h"

class Filter {
public:
    virtual ~Filter() = default;
    virtual std::vector<Song> apply() = 0;
};

#endif // FILTER_H
