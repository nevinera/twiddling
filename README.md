# Twiddling

CLI tools for managing Twiddler 4 (v7) configuration files as
human-readable text instead of using the online tuner.

## Installation

```sh
bundle install
```

Requires Ruby >= 3.3.8.

## The .tw7 format

Twiddling uses a text format (`.tw7`) for editing configs. It has an
optional settings section and a chords section separated by `=====`.
See [formats/tw7.md](formats/tw7.md) for the full specification.

```text
idle_time: 480
haptic: false
=====
1R: backspace
1M: space
1L: tab

T2::
  2R: ctrl+d
  2M: ctrl+c

[MOUSEMODE]::
  1R: left_click
  1M: middle_click
```

## Commands

### twiddling read

Print a `.cfg` or `.tw7` file as text:

```sh
bin/twiddling read my_config.cfg
bin/twiddling read layout.tw7
```

### twiddling convert

Convert between `.cfg` and `.tw7` formats:

```sh
bin/twiddling convert my_config.cfg layout.tw7
bin/twiddling convert layout.tw7 my_config.cfg
```

### twiddling search

Search for chords by button combination or output:

```sh
bin/twiddling search my.cfg --chord "T4 1M"
bin/twiddling search my.tw7 --result "@"
bin/twiddling search my.cfg --button T4 --button 0M
```

All filters are combined as AND conditions.

### Standalone conversion scripts

```sh
bin/cfg2tw7 input.cfg output.tw7
bin/cfg2tw7 input.cfg              # prints to stdout
bin/tw72cfg input.tw7 output.cfg
```

## Binary format

Config files use a binary format documented in
[formats/v7-cfg.md](formats/v7-cfg.md). Files should be named `1.cfg`,
`2.cfg`, or `3.cfg` when placed on the device.

## Credits

The v7 binary format was originally reverse-engineered by the
[nchorder](https://github.com/GlassOnTin/nchorder) project.
