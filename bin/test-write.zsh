#!/usr/bin/env zsh

# Create the usage table if it doesn't exist
if ! [[ -f user.sqlite3 ]]; then
    echo 'CREATE TABLE "usage" ("id" string UNIQUE NOT NULL,"count" integer NOT NULL DEFAULT 1, PRIMARY KEY (id));' | sqlite3 user.sqlite3
fi

# Upsert
echo "INSERT INTO usage(id) VALUES($1) ON CONFLICT(id) DO UPDATE SET count=count+1;" | sqlite3 user.sqlite3