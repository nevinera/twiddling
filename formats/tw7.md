# Twiddler Configuration Text Format (.tw7)

A human-readable text format for Twiddler 4 configurations. Can be
converted to and from the binary `.cfg` format.

## File structure

A `.tw7` file has two sections separated by a divider line (five or more
`=` characters). The first section contains settings, the second
contains chords. If no divider is present, the entire file is chords.

```text
idle_time: 480
key_repeat: false
=====
T4 F1M: f
F1L: backspace
```

## Comments

Lines starting with `#`, or inline `#` after content, are comments.
Comments are not recognized inside double-quoted strings.

```text
# This is a comment
F1L: backspace  # so is this
F1R: "hello #world"  # the # inside quotes is literal
```

## Settings section

Key-value pairs separated by a colon. Settings not specified use the
defaults from an empty tuner config.

### Available settings

| Name | Type | Default | Description |
|------|------|---------|-------------|
| idle_time | integer | 600 | Seconds until sleep |
| key_repeat | boolean | true | Key repeat enabled |
| key_repeat_delay | integer | 100 | Repeat threshold (10ms units) |
| haptic | boolean | true | Haptic feedback enabled |
| keyboard_mode | boolean | false | Button mode: keyboard |
| nav_sensitivity | integer | 4 | Navigation sensitivity (0-31) |
| nav_invert_x | boolean | false | Invert X axis |
| nav_direction | integer | 0 | Nav-up direction (0=N, 1=E, ...) |

### Thumb modifier assignments

| Name | Type | Default | Description |
|------|------|---------|-------------|
| t1_modifier | string | none | T1 modifier (see below) |
| t2_modifier | string | l_option | T2 modifier |
| t3_modifier | string | l_control | T3 modifier |
| t4_modifier | string | l_shift | T4 modifier |

Modifier values: none, l_control, l_shift, l_option, l_command.

### Dedicated button functions

| Name | Type | Default | Description |
|------|------|---------|-------------|
| f0l_dedicated | string | mouse_right | F0L dedicated function |
| f0m_dedicated | string | mouse_middle | F0M dedicated function |
| f0r_dedicated | string | mouse_left | F0R dedicated function |
| t0_dedicated | string | mouse_left | T0 dedicated function |

Dedicated function values: none, mouse_left, mouse_right, mouse_middle.

## Chords section

Each chord maps a button combination to an effect (key, modifier+key,
device function, or string).

### Basic chords

A chord is a button combination followed by a colon and an effect:

```text
F1R: c
F1M: space
T14 F4L: tab
```

### Button notation

Buttons use T4 chord notation. The `T` or `F` prefix is optional for
finger buttons - `4L` is equivalent to `F4L`. Button names are
case-insensitive.

| Type | Syntax | Examples |
|------|--------|---------|
| Thumb | T followed by digits | T1, T14, T234 |
| Finger | F followed by row and columns | F1R, F2LR, F0M |
| Finger (short) | Row and columns only | 1R, 2LR, 0M |

Multiple buttons in a chord are space-separated:

```text
T4 F1M: up
F1L F2L: 1
```

Buttons within the same row can be combined:

```text
F1LR: =     # F1L and F1R together
```

### Effects

| Type | Syntax | Examples |
|------|--------|---------|
| Key | key name | c, space, enter, f1 |
| Shifted | shifted symbol | @, !, # |
| Modified | modifier+key | ctrl+c, cmd+shift+a |
| String | double-quoted | "the ", "hello" |
| Device function | function name | speed_cycle, left_click |

#### Key names

Letters (a-z), digits (0-9), and symbols (-, =, [, ], \, ;, ', `,
comma, ., /). Special keys: enter, esc, backspace, tab, space, delete,
insert, home, end, page_up, page_down, up, down, left, right,
caps_lock, num_lock, f1-f12.

Shifted symbols can be used directly: @, !, #, $, %, ^, &, *, (, ),
\_, +, {, }, |, :, ", ~, <, >, ?.

#### Modifiers

ctrl, alt, cmd, shift - combined with `+`:

```text
F1R: ctrl+c
F2L: cmd+shift+a
```

#### Device functions

| Name            | Description          |
|-----------------|----------------------|
| mouse_toggle    | Toggle mouse mode    |
| left_click      | Left mouse click     |
| middle_click    | Middle mouse click   |
| right_click     | Right mouse click    |
| scroll_toggle   | Toggle scroll mode   |
| speed_cycle     | Cycle mouse speed    |
| speed_increase  | Increase mouse speed |
| speed_decrease  | Decrease mouse speed |
| print_stats     | Print device stats   |
| config_cycle    | Cycle configuration  |

#### Strings

Double-quoted strings produce multi-character output. Characters inside
are typed as a sequence of keypresses:

```text
F3L: "the "
F3M: "ing "
```

Uppercase letters in strings are automatically shifted. The `#`
character inside quotes is literal, not a comment.

### Grouping

A button combination followed by `::` (double colon) starts a group.
Indented chords below it are unioned with the group's buttons:

```text
T1::
  F1M: space
  F2M: "hello"
```

This is equivalent to:

```text
T1 F1M: space
T1 F2M: "hello"
```

Groups do not nest. A group ends when a non-indented line is
encountered.

### Grouping on output

When converting a binary config to `.tw7`, chords are grouped by thumb
button combination: first chords with no thumb buttons, then T1, T2,
T3, T4, T12, T13, etc.

## Example

```text
idle_time: 480
haptic: false
t1_modifier: l_command
=====
# Single-finger keys
F1L: backspace
F1M: space
F1R: tab

# Two-finger combinations
F1L F2L: 1
F1M F2L: c

# Thumb-modified groups
T1::
  F1M: enter
  F2M: "the "

T4::
  F1M: up
  F1R: page_up

# Device functions
T14 F4L: speed_cycle
```
