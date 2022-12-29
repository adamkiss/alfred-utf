#!/usr/bin/env php
<?php

$list = file(__DIR__ . '/data-python2-symbols.txt');

$cleaned = array_map(
    function ($character) {
        if (strpos($character[1], '#') !== false) {
            $character = [$character[0], ...preg_split('/\#/u', $character[1], flags: PREG_SPLIT_NO_EMPTY)];
        }
        return array_map(fn($char) => rtrim(mb_substr($char, 1), "\n"), $character);
    },
    array_filter(
        array_map(
            fn($line) => preg_split('/\|/u', $line, flags: PREG_SPLIT_NO_EMPTY),
            $list
        ),
        fn($char) => (count($char) > 3 || mb_strpos($char[1], '#') !== false)
    )
);

$invisible = array_filter($cleaned, fn($char) => $char[2] === 'invisible');
$other = array_filter($cleaned, fn($char) => !in_array($char, $invisible));

// ?