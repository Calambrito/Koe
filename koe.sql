CREATE TABLE User (
    user_id VARCHAR PRIMARY KEY,
    user_name VARCHAR NOT NULL,
    password VARCHAR NOT NULL,
    user_type VARCHAR
);
CREATE TABLE Artist (
    artist_id VARCHAR PRIMARY KEY,
    artist_name VARCHAR NOT NULL
);
CREATE TABLE Notification (
    notification_id VARCHAR PRIMARY KEY,
    user_id VARCHAR,
    artist_id VARCHAR,
    message VARCHAR,
    FOREIGN KEY(user_id) REFERENCES User(user_id),
    FOREIGN KEY(artist_id) REFERENCES Artist(artist_id)
);
CREATE TABLE Subscription (
    user_id VARCHAR,
    artist_id VARCHAR,
    PRIMARY KEY(user_id, artist_id),
    FOREIGN KEY(user_id) REFERENCES User(user_id),
    FOREIGN KEY(artist_id) REFERENCES Artist(artist_id)
);
CREATE TABLE Songs (
    song_id VARCHAR PRIMARY KEY,
    song_name VARCHAR NOT NULL,
    url VARCHAR NOT NULL,
    duration VARCHAR,
    genre VARCHAR
);
CREATE TABLE Playlist (
    playlist_id VARCHAR PRIMARY KEY,
    playlist_name VARCHAR NOT NULL,
    name VARCHAR,
    user_id VARCHAR,
    FOREIGN KEY(user_id) REFERENCES User(user_id)
);
CREATE TABLE Playlist_Songs (
    playlist_id VARCHAR,
    song_id VARCHAR,
    PRIMARY KEY(playlist_id, song_id),
    FOREIGN KEY(playlist_id) REFERENCES Playlist(playlist_id),
    FOREIGN KEY(song_id) REFERENCES Songs(song_id)
);
