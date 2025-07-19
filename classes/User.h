#ifndef USER_H
#define USER_H

#include <string>

enum class Theme {
    Light,
    Dark
};

class User {
public:
    std::string username;
    Theme theme;

    User(const std::string& username, Theme theme);
};

#endif // USER_H
