CREATE TABLE IF NOT EXISTS memo (
    id           INTEGER NOT NULL PRIMARY KEY,
    title        VARCHAR(255) default '',
    body         text,
    created_on   INTEGER,
    updated_on   INTEGER
);
