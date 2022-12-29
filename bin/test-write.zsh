#!/usr/bin/env zsh

/usr/bin/sqlite3 user.sqlite3 <<EOF
    CREATE TABLE IF NOT EXISTS "usage" (
        "id" string UNIQUE NOT NULL,
        "count" integer NOT NULL DEFAULT 1,
        PRIMARY KEY (id)
    );

    INSERT INTO
        usage(id)
        VALUES('$hex')
    ON CONFLICT(id) DO
        UPDATE SET count=count+1;
EOF