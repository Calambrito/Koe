#ifndef DISCOVER_H
#define DISCOVER_H

#include <string>
#include <vector>
#include "Song.h"
#include "Filter.h"

class Discover {
private:
    Filter* filter;

public:
    std::string searchQuery;

    Discover();

    void setFilter(Filter* newFilter);
    std::vector<Song> executeFilter();
};

#endif // DISCOVER_H
