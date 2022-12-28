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
SELECT *, rank
FROM characters('$query')
ORDER BY rank, length(name)
LIMIT 50;
EOF