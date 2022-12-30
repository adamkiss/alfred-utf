#!/usr/bin/env zsh

# Load the top 9 and display the as alfred results
/usr/bin/sqlite3 user.sqlite3 <<EOF
ATTACH "./unicode.sqlite3" as u;
CREATE TABLE IF NOT EXISTS "usage" (
	"id" string UNIQUE NOT NULL,
	"count" integer NOT NULL DEFAULT 1,
	PRIMARY KEY (id)
);

-- the query
WITH top AS (
	SELECT id, count, hex, codepoint, character, name, altname, category, html, json
	FROM main.usage
	LEFT JOIN u.characters ON usage.id = characters.hex
	ORDER BY count DESC
	LIMIT 9
)
-- the formatter
select IIF(
	count(*) > 0,
	JSON_OBJECT(
		'items', JSON_GROUP_ARRAY(
			JSON_OBJECT(
				'variables', JSON_OBJECT('hex', hex),
				'title', character || "   (" || count || "×)",
				'subtitle', name || iif(altname is not null, " / " || altname, '') || " (" || category ||  ")",
				'icon', JSON_OBJECT('path', 'icon.png'),
				'arg', character,
				'mods', JSON_OBJECT(
					'cmd', JSON_OBJECT(
						'arg', html,
						'subtitle', 'Copy & paste as HTML → "' || html || '"'
					),
					'option', JSON_OBJECT(
						'arg', json,
						'subtitle', 'Copy & paste as JS/Python/… → "' || json || '"'
					),
					'option+cmd', JSON_OBJECT(
						'arg', "\u{" || codepoint || "}",
						'subtitle', 'Copy & paste as PHP → "\u{' || codepoint || '}"'
					),
					'ctrl', JSON_OBJECT(
						'arg', hex,
						'subtitle', 'Copy & paste hex → "' || hex || '"'
					),
					'ctrl+cmd', JSON_OBJECT(
						'arg', codepoint,
						'subtitle', 'Copy & paste full codepoint → "' || codepoint || '"'
					)
				),
				'text', JSON_OBJECT(
					'copy', name,
					'largetype', character || '(' || name || ')'
				)
			)
		)
	),
	JSON_OBJECT(
		'items', JSON_ARRAY(
			JSON_OBJECT(
				'valid', false,
				'title', "UTF Search: no usage yet",
				'subtitle', "Search the UTF database using 'utf <query>' first",
				'icon', JSON_OBJECT('path', 'icon.png')
			)
		)
	)
) FROM top;
EOF