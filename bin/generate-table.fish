#!/usr/bin/env fish

# wrap argument "cat" as "category:$cat" and return formatted characters from the category
function uni_category -a cat
    set capture (string join ',' (eval "$(status dirname)/uni-v2.5.1 print category:\$cat -c -f \"(%(hex q), SUBSTR(%(cpoint q), 3), %(char q), LOWER(%(name q)), %(cat q), %(html q), %(json q), %(keysym q))\""))
    string replace "'''" "''''" $capture # fucking apostrophe
end

function insert_into_characters -a cat
    echo "INSERT INTO characters (hex, codepoint, character, name, category, html, json, keysymbol) VALUES $(uni_category $cat);"
end

# Create the unicode characters database
echo "
DROP TABLE IF EXISTS characters;
CREATE VIRTUAL TABLE characters USING fts5 (
    hex,
    codepoint UNINDEXED,
    character UNINDEXED,
    name,
    altname,
    category,
    html,
    json,
    keysymbol,
    tokenize = 'porter unicode61'
);
$(insert_into_characters C)
$(insert_into_characters L)
$(insert_into_characters M)
$(insert_into_characters N)
$(insert_into_characters P)
$(insert_into_characters S)
$(insert_into_characters Z)
$(eval "php $(status dirname)/parse-unicode-data.php")
" > generate-table.sql # it's ran from main folder

# run the SQL and generate the table
/usr/bin/sqlite3 unicode.sqlite3 < generate-table.sql

# remove the file
rm generate-table.sql
