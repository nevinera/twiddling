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
See [formats/tw7.md](formats/tw7.md) for a fuller specification.

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

### twiddling diff

Compare two configs, showing changed settings and chords:

```sh
bin/twiddling diff old.cfg new.cfg
bin/twiddling diff base.tw7 mine.tw7 --no-color
```

Output is colorized by default (red=removed, yellow=changed,
green=added).

### Standalone conversion scripts

These are really necessary (and I recommend `twiddling convert`
most of the time). But simple coversion tools can be more convenient
sometimes.

```sh
bin/cfg2tw7 input.cfg output.tw7
bin/cfg2tw7 input.cfg              # prints to stdout
bin/tw72cfg input.tw7 output.cfg
```

## Binary format

Config files use a binary format documented in
[formats/v7-cfg.md](formats/v7-cfg.md). Files should be named `1.cfg`,
`2.cfg`, or `3.cfg` when placed on the device.

Note that I have not fully explored the possible chords/settings; I assume
there are some things that are no converted correctly or currently
representable in the tw7 format. Feel free to submit PRs, or include a tuner-
generated .cfg file with minimal chords in your Issue and explain what those
chords actually do (I personally only use keys, modified keys, and short
multi-character strings).

## Config Collection

There are a few full configurations in `configs/v7/`. Feel free to submit
additional configs, either as PRs or issues; if you use it as your primary
configuration (or if it's a community standard), I'm happy to include it!

## Credits

The v7 binary format was originally reverse-engineered by the
[nchorder](https://github.com/GlassOnTin/nchorder) project, though
we've departed from their interpretation pretty substantially.
