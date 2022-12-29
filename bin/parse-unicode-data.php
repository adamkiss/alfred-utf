<?php

# utils
function a(...$arg) { return $arg; }

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
        name: mb_convert_case($raw[1], MB_CASE_TITLE),
        alt: mb_convert_case($raw[10], MB_CASE_TITLE)
    );

    // Get only the difference between the alt and name, and save that
    $diffAlt  = explode(' ', $character['alt']);
    $diffName = explode(' ', $character['name']);
    while ((!empty($diffAlt) && !empty($diffName)) && $diffAlt[0] === $diffName[0]) {
        array_shift($diffAlt);
        array_shift($diffName);
    }
    $character['alt'] = implode(' ', $diffAlt);

    $data []= $character;
}

// Too many
$altNameCharacters = array_filter($data, fn($ch) => !empty($ch['alt']));
