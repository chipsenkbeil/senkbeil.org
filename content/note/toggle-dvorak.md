+++
title = "Toggle Dvorak"
date = "2016-08-12T09:36:18-05:00"
tags = [ "utility" ]
categories = [ "snippet" ]
+++

In my ArchLinux setup with XMonad, I've found myself wanting to swap
between _QWERTY_ and _Dvorak_ keyboard layouts when practicing
_Dvorak_. While my _Kinesis Advantage_ keyboard allows me to swap
layouts at the hardware level (I'm assuming by simulating Dvorak
on top of Qwerty), I also found a keyboard-agnostic way to do this.

### Configuring Keypress Toggle

For X11, create the following configuration at
`/etc/X11/xorg.conf.d/00-keyboard.conf`:

```bash
# Read and parsed by systemd-localed. It's probably wise not to edit this file
# manually too freely.
Section "InputClass"
    Identifier "system-keyboard"
    MatchIsKeyboard "on"
    Option "XkbLayout" "us,us"
    Option "XkbModel" ","
    Option "XkbVariant" ",dvorak"
    Option "XkbOptions" "grp:toggle"
EndSection
```

This enables toggling Dvorak via `Right-Alt`.

### Configuring Visual Indicator with Xmobar

So, along with XMonad, I use Xmobar to display useful information such
as my current workspace, battery charge, and time. To avoid confusing
myself when switching between keyboard layouts, I added a visual 
indicator in the right corner of Xmobar via the following:

```haskell
-- Display of Xmobar information
, template = "%StdinReader%  }{ %battery% | %multicpu% | %coretemp% | %memory% | %dynnetwork% | %KAUS% | %date% || %kbd% "

, commands =
    [
    -- Series of commands to run on Xmobar
    -- ...

    -- keyboard layout indicator
    , Run Kbd            [ ("us(dvorak)" , "<fc=#00008B>DV</fc>")
                         , ("us"         , "<fc=#8B0000>US</fc>")
                         ]
    ]
```

