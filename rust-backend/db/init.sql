CREATE TABLE IF NOT EXISTS task
(
    id          TEXT PRIMARY KEY,
    title       TEXT    NOT NULL,
    description TEXT,
    created     TEXT    NOT NULL,
    done        INTEGER NOT NULL
);
