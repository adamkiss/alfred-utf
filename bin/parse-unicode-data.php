<?php

# utils
function a(...$arg) { return $arg; }
# make intellephense shut up
if (!function_exists('ray')) { function ray(...$arg) { return $arg; }}

# Latest unicode data: https://www.unicode.org/Public/UCD/latest/ucd/

# Download latest UnicodeData.txt
if (count($argv) > 1 && $argv[1] === 'dud') {
    file_put_contents(
        __DIR__ . '/data-UnicodeData.txt',
        file_get_contents("https://www.unicode.org/Public/UCD/latest/ucd/UnicodeData.txt")
    );
}

# Get category names from uni
$categories = json_decode(shell_exec(__DIR__ . '/uni-v2.5.1 list categories -json'), associative: true);
$categories = array_reduce($categories, function ($mapped, $cat) {
    $mapped[$cat['short']] = $cat['name'];
    return $mapped;
}, []);

# load the the unicode data
$datafile = new SplFileObject(__DIR__ . '/data-UnicodeData.txt');
$data = [];
while(! $datafile->eof()) {
    $raw = $datafile->fgetcsv(separator: ';');
    if (count($raw) !== 15) {
        continue; # probably not a character?
    }

    $character = a(
        hex: $raw[0] === '0000' ? '0' : ltrim(strtolower($raw[0]), '0'),
        name: mb_strtolower($raw[1]),
        alt: mb_strtolower($raw[10])
    );

    // Simplify alt names
    $diffAlt  = explode(' ', $character['alt']);
    $diffName = explode(' ', $character['name']);
    $diffNamePreg = preg_split('/[ -]/', $character['name']);

    // if name fully contains alt, remove alt
    if (empty(array_diff($diffAlt, $diffName))) {
        $character['alt'] = '';
        continue;
    }

    // if alt is only two words instead of name's two-words, ignore
    if (empty(array_diff($diffAlt, $diffNamePreg))) {
        $character['alt'] = '';
        continue;
    }

    // if alt contains more info (like Georgian >small< letter Han),
    // replace name with alt
    if (empty(array_diff($diffName, $diffAlt))) {
        $character['name'] = $character['alt'];
        $character['alt'] = '';
        continue;
    }

    // replace <control> with alt name and ignore
    if ($character['name'] === '<control>') {
        $character['name'] = $character['alt'];
        $character['alt'] = '';
        continue;
    }

    // Get only the difference between the alt and name, and save that
    while ((!empty($diffAlt) && !empty($diffName)) && $diffAlt[0] === $diffName[0]) {
        array_shift($diffAlt);
        array_shift($diffName);
    }
    $character['alt'] = implode(' ', $diffAlt);

    $data []= $character;
}

// Now get only character that have alt name
$altNameCharacters = array_filter($data, fn($ch) => !empty($ch['alt']));


// OBSERVE
if ($argv[1] ?? false === 'debug') {
    // ignore-next-line
    ray(count($altNameCharacters));
    file_put_contents(
        __DIR__ . '/diff-name-alt.txt', 
        implode("\n", array_map(fn($ch) => "{$ch['hex']} => {$ch['name']} / {$ch['alt']}", $altNameCharacters))
    );
} else {
    echo implode('', array_map(
        fn($ch) => "UPDATE characters SET a = '{$ch['alt']}' WHERE hex = '{$ch['hex']}';",
        $altNameCharacters
    ));
}