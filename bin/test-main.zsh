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
-- the query
WITH found AS (
	SELECT character, name, category, hex, html, json, user.usage.count
	FROM main.characters('2192')
	LEFT JOIN user.usage ON main.characters.hex = user.usage.id
	ORDER BY user.usage.count DESC, rank ASC, length(name) ASC
	LIMIT 50
)
-- the formatter
select JSON_OBJECT(
	'items', JSON_GROUP_ARRAY(
		JSON_OBJECT(
			'uid', hex,
			'title', character,
			'subtitle', name || " (" || category || ")",
			'icon', JSON_OBJECT('path', 'icon.png'),
			'arg', character,
			'mods', JSON_OBJECT(
				'cmd', JSON_OBJECT(
					'arg', html,
					'subtitle', 'Copy & paste as HTML'
				),
				'option', JSON_OBJECT(
					'arg', json,
					'subtitle', 'Copy & paste as JS/Python/…'
				),
				'ctrl', JSON_OBJECT(
					'arg', hex,
					'subtitle', 'Copy & paste as Decimal value'
				)
			)
		)
	)
) FROM found;
EOF