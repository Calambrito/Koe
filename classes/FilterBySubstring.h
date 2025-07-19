#ifndef FILTER_BY_SUBSTRING_H
#define FILTER_BY_SUBSTRING_H

#include <string>
#include "Filter.h"

class FilterBySubstring : public Filter {
public:
    std::string substring;

    FilterBySubstring(const std::string& substring);

    std::vector<Song> apply() override;
};

#endif // FILTER_BY_SUBSTRING_H
