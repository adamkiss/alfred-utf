#!/usr/bin/env zsh

# trim and collapse whitespace - source: https://stackoverflow.com/a/40962059
query=`echo $1 | xargs`

# if query contains ':', it's full fts5 query
# otherwise, change multiple groups into asterisk'd AND query
# 'right arr' => 'right* AND arr*'
raw=":"
if test "${query#*$raw}" = "$query"
then
	query="${query// /* AND }*"
else
	query="$query"
fi

/usr/bin/sqlite3 unicode.sqlite3 <<EOF
ATTACH "./user.sqlite3" as user;
SELECT *, rank, usage.count
FROM main.characters('$query')
LEFT JOIN user.usage ON main.characters.hex = user.usage.id
ORDER BY user.usage.count, rank, length(name)
LIMIT 50;
EOF