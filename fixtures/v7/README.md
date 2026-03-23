## Fixtures

* empty.cfg - config downloaded with only system chords and default settings
* large.cfg - a full config with many chords.
* settings:
  - no-right-mouse-button.cfg - same as empty.cfg, but with the 'dedicated
    button function' removed from 0L (previously was 'Mouse Button Right')
  - no-t0-dedicated.cfg - empty.cfg but with the t0 no longer dedicated to
    mouse button left.
  - idle-time-8m.cfg - Same as empty.cfg, but with the 'idle time until sleep'
    lowered from 10m to 8m
  - nav-invert-x-axis.cfg - empty.cfg with 'Nav Invert X-Axis' enabled
  - nav-sensitivity-lowered.cfg - empty cfg with 'nav sensitivity' reduced
    by one notch.
  - button-mode-keyboard.cfg - empty.cfg but with button-mode set to "keyboard"
  - haptic-feedback-off.cfg - empty.cfg but with haptic feedback disabled
  - nav-up-east.cfg - empty.cfg but with nav-up set to east instead of north.
  - key-repeat-disabled.cfg - empty.cfg but with key-repeat disabled
  - key-repeat-1020.cfg - empty.cfg, but with the key-repeat threshold changed
    from 1000 to 1020 ms
* buttons:
  - single-unmodified-key.cfg - empty.cfg but with: F1R = "c"
  - shifted-key.cfg - empty.cfg but with: F1R = "@"
  - modifier-key.cfg - empty.cfg but with: F1R = "ctrl+c"
  - multi-char.cfg - empty.cfg but with: F1R = "test" (a string)
  - cycle-config-chord.cfg - empty.cfg but with: F1R = "Cycle config"
  - mini-buttons.cfg - empty.cfg but with: 0L = "l", 0M = "m", and 0R = "r"
