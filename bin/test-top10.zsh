#!/usr/bin/env zsh

# Create the usage table if it doesn't exist
if ! [[ -f user.sqlite3 ]]; then
    echo 'CREATE TABLE "usage" ("id" string UNIQUE NOT NULL,"count" integer NOT NULL DEFAULT 1, PRIMARY KEY (id));' | sqlite3 user.sqlite3
fi

/usr/bin/sqlite3 user.sqlite3 <<EOF
ATTACH "./unicode.sqlite3" as u;
-- the query
WITH top10 AS (
	SELECT id, count, hex, character, name, category, html, json
	FROM main.usage
	LEFT JOIN u.characters ON usage.id = characters.hex
	ORDER BY count DESC
	LIMIT 10
)
-- the formatter
select JSON_OBJECT(
	'items', JSON_GROUP_ARRAY(
		JSON_OBJECT(
			'uid', hex,
			'variables', JSON_OBJECT('hex', hex),
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
) FROM top10;
EOF