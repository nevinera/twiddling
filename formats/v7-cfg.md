# Twiddler 4 Binary Configuration Format (v7)

The Twiddler 4 uses a binary `.cfg` format for its configuration files.
The format is informally called "v7", after the format version byte in
the flags field.

## Credits

The binary format was originally reverse-engineered by the
[nchorder](https://github.com/GlassOnTin/nchorder) project
([spec](https://github.com/GlassOnTin/nchorder/blob/master/docs/twiddler4/06-CONFIG_FORMAT.md)).
This documentation builds on that work, validated and extended using
configs produced by the official
[Twiddler tuner](https://tuner.mytwiddler.com).

## File structure

A v7 config file has three sections laid out sequentially:

1. **Header** - 128 bytes (offsets 0x00-0x7F)
1. **Chord entries** - 8 bytes each (starting at offset 0x80)
1. **String table** - variable length, immediately after the last chord

The string table begins at offset `128 + (chord_count * 8)`. There is no
pointer to it in the header - its location is computed from the chord
count.

All multi-byte integers are little-endian.

## Header (128 bytes)

| Offset | Size | Type | Field | Description |
|--------|------|------|-------|-------------|
| 0x00 | 4 | u32 | version | Always 0 in observed configs |
| 0x04 | 1 | u8 | format_version | Always 7 (the "v7" in the format name) |
| 0x05 | 1 | u8 | flags_1 | See [Flags byte 1](#flags-byte-1) |
| 0x06 | 1 | u8 | flags_2 | See [Flags byte 2](#flags-byte-2) |
| 0x07 | 1 | u8 | flags_3 | Always 0x00 in observed configs |
| 0x08 | 2 | u16 | chord_count | Number of chord entries |
| 0x0A | 2 | u16 | idle_time | Seconds until sleep (default 600 = 10 min) |
| 0x0C | 2 | u16 | key_repeat | Repeat threshold in 10ms units (default 100) |
| 0x0E | 2 | - | reserved_0e | Always 0 in observed configs |
| 0x10 | 48 | - | reserved_10 | Always all zeros |
| 0x40 | 4 | u32 | thumb_t1_modifier | Thumb button T1 modifier assignment |
| 0x44 | 4 | u32 | thumb_t2_modifier | Thumb button T2 modifier assignment |
| 0x48 | 4 | u32 | thumb_t3_modifier | Thumb button T3 modifier assignment |
| 0x4C | 4 | u32 | thumb_t4_modifier | Thumb button T4 modifier assignment |
| 0x50 | 1 | u8 | dedicated_f0l | Dedicated button function for F0L |
| 0x51 | 1 | u8 | dedicated_f0m | Dedicated button function for F0M |
| 0x52 | 1 | u8 | dedicated_f0r | Dedicated button function for F0R |
| 0x53 | 1 | u8 | dedicated_t0 | Dedicated button function for T0 |
| 0x54 | 12 | - | reserved_54 | Always all zeros |
| 0x60 | 32 | u8[32] | index_table | See [Index table](#index-table) |

### Flags byte 1 (offset 0x05)

| Bit | Mask | Meaning | Default |
|-----|------|---------|---------|
| 0 | 0x01 | Key repeat enabled | 1 (enabled) |
| 1 | 0x02 | Button mode: keyboard | 0 (chord mode) |
| 3 | 0x08 | Haptic feedback enabled | 1 (enabled) |

Default value: 0x09 (key repeat + haptic enabled).

### Flags byte 2 (offset 0x06)

This byte encodes navigation settings as a composite value:

```text
  Bits 7-3: Nav sensitivity (0-31, default 4)
  Bit 2:    Invert X axis (0 = normal, 1 = inverted)
  Bits 1-0: Nav-up direction (0 = north, 1 = east, ...)
```

The byte value is: `(sensitivity << 3) | (invert_x << 2) | direction`

| Example | Value | Sensitivity | Invert X | Direction |
|---------|-------|-------------|----------|-----------|
| Default | 0x20 | 4 | no | north |
| Sensitivity min | 0x00 | 0 | no | north |
| Invert X | 0x24 | 4 | yes | north |
| Nav-up east | 0x21 | 4 | no | east |

### Thumb modifier assignments (offsets 0x40-0x4F)

Each thumb button can be assigned a modifier key. Stored as four u32 LE
values (one per thumb button, T1-T4):

| Code | Modifier |
|------|----------|
| 0 | Num (default for T1) |
| 1 | LControl (default for T3) |
| 2 | LShift (default for T4) |
| 3 | LOption / Alt (default for T2) |
| 4 | LCommand / Windows |

Default assignments: T1=Num(0), T2=LOption(3), T3=LControl(1), T4=LShift(2).

### Dedicated button functions (offsets 0x50-0x53)

Each of the four special buttons (three mini-buttons + T0) can have a
dedicated function that fires on press without requiring a chord. Stored
as four u8 values:

| Offset | Button | Default | Function |
|--------|--------|---------|----------|
| 0x50 | F0L | 0x0a | Mouse Button Right |
| 0x51 | F0M | 0x0b | Mouse Button Middle |
| 0x52 | F0R | 0x09 | Mouse Button Left |
| 0x53 | T0 | 0x09 | Mouse Button Left |

A value of 0x00 means no dedicated function.

Known function codes:

| Code | Function |
|------|----------|
| 0x00 | None (disabled) |
| 0x09 | Mouse Button Left |
| 0x0a | Mouse Button Right |
| 0x0b | Mouse Button Middle |

Note: These codes differ from the chord device function codes.

### Index table (offset 0x60, 32 bytes)

A lookup table for fast chord matching. Each of the 32 entries
corresponds to the low 5 bits of a chord's bitmask (the "prefix").
The value at each entry is the index of the first chord in the sorted
chord array that has that prefix. A value of 0x80 means no chords exist
with that prefix.

Chords **must** be sorted by bitmask in ascending order for the index
table to function correctly. The index table must be recomputed whenever
chords are added or removed.

## Chord entry (8 bytes)

| Offset | Size | Type | Field |
|--------|------|------|-------|
| 0 | 4 | u32 LE | bitmask |
| 4 | 2 | u16 LE | modifier_type |
| 6 | 2 | u16 LE | keycode |

### Bitmask

The bitmask encodes which physical buttons are pressed. The Twiddler 4
has 21 buttons: 5 thumb buttons (T0-T4), 15 finger buttons (rows 0-4,
columns L/M/R), plus a mouse-mode flag.

| Bit | Button | Bit | Button | Bit | Button |
|-----|--------|-----|--------|-----|--------|
| 0 | T1 | 8 | T3 | 16 | F0L |
| 1 | F1L | 9 | F3L | 17 | F0M |
| 2 | F1M | 10 | F3M | 18 | F0R |
| 3 | F1R | 11 | F3R | 19 | mouse-mode-only |
| 4 | T2 | 12 | T4 | | |
| 5 | F2L | 13 | F4L | | |
| 6 | F2M | 14 | F4M | | |
| 7 | F2R | 15 | F4R | | |

Bits 0-18 encode physical buttons. Bit 19 is a flag: when set, the
chord is only active in mouse mode. Bits 20-31 are unused (always 0 in
observed configs). T0 does not appear in the bitmask - it only has a
dedicated button function.

The buttons are named using
[T4 chord notation](https://www.mytwiddler.com/doc/doku.php?id=chordnotation):

- Thumb buttons: `T1`, `T2`, `T3`, `T4`
- Finger buttons: `F<row><L|M|R>` (e.g. `F1R`, `F2L`, `F0M`)
- Row 0 is the mini-buttons above the main finger pad

### Modifier/type field

The low byte encodes the chord type. The high byte's meaning depends on
the type:

| Type | Low byte | High byte meaning |
|------|----------|-------------------|
| Device function | 0x01 | Function code |
| Keyboard | 0x02 | Modifier key bits |
| Multi-char string | 0x07 | String table byte offset |

#### Keyboard modifier bits (high byte, type 0x02)

| Bit | Mask | Modifier |
|-----|------|----------|
| 0 | 0x01 | Ctrl |
| 2 | 0x04 | Alt |
| 3 | 0x08 | Cmd / Windows |
| 5 | 0x20 | Shift |

#### Device function codes (high byte, type 0x01)

| Code | Function |
|------|----------|
| 0x01 | Mouse mode toggle |
| 0x02 | Left click |
| 0x04 | Scroll mode toggle |
| 0x05 | Speed decrease |
| 0x06 | Speed cycle |
| 0x0a | Middle click |
| 0x0b | Speed increase |
| 0x0c | Right click |
| 0x0d | Print stats |
| 0x0e | Config cycle |

The keycode field is 0x0000 for device function chords.

#### Multi-char string (type 0x07)

The high byte of the modifier_type field is the byte offset into the
string table where the character sequence for this chord begins. The
keycode field is 0x0000.

### Keycode

For keyboard chords (type 0x02), this is a standard USB HID keycode:

| Range | Keys |
|-------|------|
| 0x04-0x1D | a-z |
| 0x1E-0x27 | 1-0 (number row) |
| 0x28 | Enter |
| 0x29 | Escape |
| 0x2A | Backspace |
| 0x2B | Tab |
| 0x2C | Space |
| 0x2D-0x38 | Punctuation: - = [ ] \ ; ' ` , . / |
| 0x39 | Caps Lock |
| 0x3A-0x45 | F1-F12 |
| 0x49 | Insert |
| 0x4A | Home |
| 0x4B | Page Up |
| 0x4C | Delete |
| 0x4D | End |
| 0x4E | Page Down |
| 0x4F-0x52 | Right, Left, Down, Up arrows |
| 0x53 | Num Lock |

## String table

The string table stores character sequences for multi-char chords. It
immediately follows the chord entries (no header pointer - the location
is computed from the chord count).

Each entry is a sequence of (modifier u16 LE, HID keycode u16 LE) pairs
terminated by a null pair (0x0000, 0x0000):

```text
[mod1:u16][key1:u16][mod2:u16][key2:u16]...[0x0000][0x0000]
```

The modifier values use the same encoding as keyboard chord modifier_type
fields: 0x0002 for an unmodified key, 0x2002 for Shift, etc.

### Example: "test"

```text
Offset 0: (0x0002, 0x0017)  t
Offset 4: (0x0002, 0x0008)  e
Offset 8: (0x0002, 0x0016)  s
Offset C: (0x0002, 0x0017)  t
Offset 10: (0x0000, 0x0000) terminator
```

The chord entry's modifier_type high byte would be 0x00 (byte offset 0
into the string table), giving a full modifier_type of 0x0007.

A second string entry would start at offset 0x14 (20 bytes), and its
chord's modifier_type would be 0x1407.
