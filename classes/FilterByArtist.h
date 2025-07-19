#ifndef FILTER_BY_ARTIST_H
#define FILTER_BY_ARTIST_H

#include <string>
#include "Filter.h"

class FilterByArtist : public Filter {
public:
    std::string artistName;

    FilterByArtist(const std::string& artistName);

    std::vector<Song> apply() override;
};

#endif // FILTER_BY_ARTIST_H
