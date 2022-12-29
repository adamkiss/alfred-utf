#!/usr/bin/env fish

set -l utf_version (defaults read "$(pwd)/info" version)
zip "./dist/alfred-utf-$utf_version.alfredworkflow" info.plist icon.png Readme.md unicode.sqlite3