#!/usr/bin/env zsh

# trim and collapse whitespace - source: https://stackoverflow.com/a/40962059
query=`echo $1 | xargs`

# prepare the user database (it must exist)
/usr/bin/sqlite3 user.sqlite3 <<INIT
CREATE TABLE IF NOT EXISTS "usage" (
	"id" string UNIQUE NOT NULL,
	"count" integer NOT NULL DEFAULT 1,
	PRIMARY KEY (id)
);
INIT

# CASE: give me help
if [[ "$query" == "!h" ]]; then
cat << HELP
{
	"items": [
		{
			"title": "👉 \`utf <query>\`",
			"autocomplete": "right arrow",
			"subtitle": "Search for a Unicode character with name, altname, html or hex matching <query>",
			"valid": false
		},
		{
			"title": "🔍 \`utf !<character>\`",
			"autocomplete": "!!",
			"subtitle": "Get details for a <character>…",
			"valid": false
		},
		{
			"title": "🆘 \`utf !h\`",
			"subtitle": "…except '!h', which returns this help",
			"valid": false
		},
		{
			"title": "🥩 \`utf :<query>\`",
			"autocomplete": ":sea* AND Other*",
			"subtitle": "Start query with a colon to use raw SQLite FTS5 Match syntax (the underlying technology)",
			"valid": false
		},
		{
			"title": "💡 tip: \`utf u0021\`",
			"autocomplete": "u0021",
			"subtitle": "Will mostly match the json field, so you can easily query exact Unicode codepoints",
			"valid": false
		},
		{
			"title": "💡 tip: \`utf larr\`",
			"autocomplete": "larr",
			"subtitle": "Use HTML named entities to quickly match useful characters",
			"valid": false
		}
	]
}
HELP
exit
fi

# CASE: give me character
# query starts with !, it's a "give me character X query"
if [[ "$query" =~ ^! ]]; then
/usr/bin/sqlite3 unicode.sqlite3 <<SQL
	ATTACH "./user.sqlite3" as user;
	-- the query
	WITH found AS (
		SELECT hex, codepoint, character, name, altname, category, html, json, user.usage.count
		FROM main.characters
		LEFT JOIN user.usage ON cast(user.usage.id as text) = cast(characters.hex as text)
		WHERE character = SUBSTR('$query', 2)
		ORDER BY user.usage.count
	)
	-- the formatter
	select JSON_OBJECT(
		'items', JSON_GROUP_ARRAY(
			JSON_OBJECT(
				'variables', JSON_OBJECT('hex', hex),
				'title', character,
				'subtitle', name || iif(altname is not null, " / " || altname, '') || " (" || category || IIF(count > 0, ", " || count, '') || ")",
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
					'ctrl+option', JSON_OBJECT(
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
	) FROM found;
SQL
exit
fi

# CASE: fulltext over name, altname, and other fields
# if query contains ':', it's full fts5 query
# otherwise, change multiple groups into asterisk'd AND query
# 'right arr' => 'right* AND arr*'
if [[ "${query#*':'}" == "$query" ]]; then
	query="${query// /* AND }*"
else
	query="${query#*':'}"
fi

/usr/bin/sqlite3 unicode.sqlite3 <<SQL
	ATTACH "./user.sqlite3" as user;
	-- the query
	WITH found AS (
		SELECT hex, codepoint, character, name, altname, category, html, json, user.usage.count
		FROM main.characters('$query')
		LEFT JOIN user.usage ON cast(user.usage.id as text) = cast(characters.hex as text)
		ORDER BY user.usage.count DESC, rank ASC, length(name) ASC
		LIMIT 50
	)
	-- the formatter
	select JSON_OBJECT(
		'items', JSON_GROUP_ARRAY(
			JSON_OBJECT(
				'variables', JSON_OBJECT('hex', hex),
				'title', character,
				'subtitle', name || iif(altname is not null, " / " || altname, '') || " (" || category || IIF(count > 0, ", " || count, '') || ")",
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
					'ctrl+option', JSON_OBJECT(
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
	) FROM found;
SQL
