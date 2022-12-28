#!/usr/bin/env fish

# wrap argument "cat" as "category:$cat" and return formatted characters from the category
function uni_category -a cat
    ./uni print category:$cat -c -f "('%(char)', LOWER('%(name)'), '%(cat)', '%(hex)', '%(keysym)'),"
end

# join the results of (uni_category $cat) and trim trailing ','
function uni_to_values -a cat
    set return (string trim -r -c , (string join '' (uni_category $cat)))
    # escape APOSTROPHE for the SQL
    string replace "'''" '"\'"' $return
end

function insert_into_characters -a values
    echo "INSERT INTO characters (character, name, category, hex, keysymbol) VALUES $values;"
end

# Create the unicode characters database
echo "
DROP TABLE IF EXISTS characters;
CREATE VIRTUAL TABLE characters USING fts5 (
    character UNINDEXED,
    name,
    category,
    hex,
    html,
    keysymbol,
    tokenize = 'porter unicode61'
);
$(insert_into_characters (uni_to_values C))
$(insert_into_characters (uni_to_values L))
$(insert_into_characters (uni_to_values M))
$(insert_into_characters (uni_to_values P))
$(insert_into_characters (uni_to_values S))
$(insert_into_characters (uni_to_values Z))
" > generate-table.sql # it's ran from main folder

# run the SQL and generate the table
/usr/bin/sqlite3 unicode.sqlite3 < generate-table.sql

# remove the file
rm generate-table.sql
