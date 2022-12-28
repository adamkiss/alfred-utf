# <img src="https://user-images.githubusercontent.com/481362/209873324-855bb383-5998-4377-90ee-5bee67d5cc79.png" width="40" height="40"/> Alfred-uni ![Version badge](https://shields.io/github/v/release/adamkiss/alfred-utf?display_name=tag&include_prereleases&sort=semver)

![Alfred-utf - workflow screenshot](https://user-images.githubusercontent.com/481362/209873321-da2ca012-a430-4193-b88e-c6332e46fc1e.jpg)

Simple workflow to replace now defunct Python 2 workflow. Uses pure SQLite3 - with fts5 and json1 extensions - which is still packaged with MacOS, unlike PHP or Python 2 in versions of MacOS 13+.

## Usage

- `utf` - Search for a Unicode character
    - Default action: copy the character (e.g. `→`)
    - <kbd>Cmd</kbd> - copy the HTML version (e.g. `&rarr;`)
    - <kbd>Option</kbd> - copy the Unicode point for js/php/python/… (e.g. `\u2192`)
    - <kbd>Ctrl</kbd> - copy the decimal value for whatever reason (e.g. `2192`) 
- `utf :whatever*` - If your query starts with **colon**, you are writing raw SQLite fts5 match syntax. Use only if you desire to fool around with stuff.
- `utf10` - Top 10 characters you've used in the past, with count of times you've used them

## Installation

1. Download the workflow
2. Use the workflow

## License

MIT License - see [LICENSE](./LICENSE)
© 2022 Adam Kiss. Databased was sourced with [Uni by Martin Tournoij](https://github.com/arp242/uni)