+++
title = "Xorg & eGPU"
slug = "xorg-egpu"
date = "2019-06-19"
categories = []
tags = []
+++

## Initial attempt

On Fedora, installed `xorg-x11-drv-amdgpu`. Not sure if needed, but can now
detect my eGPU and the displays light up temporarily, but then turn off with no
signal.

## Fixing the black screens

Followed https://egpu.io/forums/builds/mid-2012-13-macbook-pro-rx46010gbps-tb1-3-linux-mint-19-build-guide-benchmarks-nu_ninja/

Created the following files:

1. __/etc/X11/xorg.conf.d/egpu-layout.conf:__
```
Section "ServerLayout"
    Identifier "egpu"
    Screen 0 "amdgpu"
    Inactive "intel"
EndSection

Section "ServerLayout"
    Identifier "laptop"
    Screen 0 "intel"
    Inactive "amdgpu"
EndSection

Section "Device"
    Identifier "amdgpu"
    Driver "amdgpu"

    # BusID in decimal, convert from hex of 0f:00.0
    # after running lspci | grep VGA
    BusID "PCI:15:0:0"
    Option "AllowEmptyInitialConfiguration"
    Option "AllowExternalGpus"
EndSection

Section "Screen"
    Identifier "amdgpu"
    Device "amdgpu"
EndSection

Section "Device"
    Identifier "intel"
    Driver "modesetting"

    # BusID in decimal, convert from hex of 02:00.0
    # after running lspci | grep VGA
    BusID "PCI:0:2:0"
EndSection

Section "Screen"
    Identifier "intel"
    Device "intel"
EndSection
```

2. __/etc/X11/xorg.conf.d/inactive/01-laptop.conf:__
```
Section "ServerFlags"
    Option "DefaultServerLayout" "laptop"
EndSection
```

3. __/etc/init.d/egpu-sync:__
```
#!/bin/sh

#Script should be safe as long as DIR and FILE don't point to anything valuable
DIR=/etc/X11/xorg.conf.d
FILE=01-laptop.conf

TEST=$(lspci | grep -c " VGA ")

#Check TEST against number of gpus including egpu
if ([ $TEST -eq 2 ]); then
    #eGPU Connected
    if ([ -e $DIR/$FILE ]); then
        rm $DIR/$FILE
    fi
else
    #No eGPU or unexpected number/output
    if ([ -e $DIR/$FILE ]); then
        break
    else
        if ([ -e $DIR/inactive/$FILE ]); then
            cp $DIR/inactive/$FILE $DIR/$FILE
        fi
    fi
fi
```

Then, symlinked as mentioned in the post via `ln -s /etc/init.d/egpu-sync
/etc/rc5.d/S15egpu-sync`.

Finally, exited XMonad and re-logged into my session and the laptop screen is
turned off with the external displays working.

## Handling the bigger resolution

My external displays are 4k (3840x2160 at 60 FPS) and XMonad does not scaling
for these displays. So, the text looks tiny as do all of the controls.

From my eGPU, I'm using DisplayPort-2, DisplayPort-3, and DisplayPort-4
devices. To fix the scale, I ran
`xrandr --output DisplayPort-2 --scale 0.5x0.5` for each of the three displays.

Projects like https://github.com/ashwinvis/xrandr-extend may do this for me.

Note that https://wiki.archlinux.org/index.php/HiDPI#X_Resources (ArchLinux
wiki for HiDPI) mentions that you can adjust the sharpness of the monitors to
counteract the scaling.

## TODO

### Multiple xmobar instances

xmobar is only running on one of my displays. Need to get it to run on all of
them using `spawnPipe $ "xmobar -x " ++ show sid` for each screen as described
on reddit https://www.reddit.com/r/xmonad/comments/9vg646/xmobar_with_multiple_monitors/

A good explanation of the `xmobar` helper, the `statusBar` helper, and the
`avoidStruts` and other related helpers I've been using is https://wiki.archlinux.org/index.php/HiDPI#X_Resources

Additionally, I could consider independent screens via https://hackage.haskell.org/package/xmonad-contrib-0.15/docs/XMonad-Layout-IndependentScreens.html

### Enable internal display with eGPU

I should also check to see if I can still have the internal display on such
that when I disconnect my egpu I still have a screen (or if I need to log out
each time).

### Fix weird scaling with internal display

After disconnecting the eGPU when using the external displays, I was unable to
recover my internal display, even when trying to exit XOrg blindly. Probably
need to exit XOrg first before disconnecting.

Because of this, I had to reboot my computer. The login manager was fine and I
was able to log back into XMonad (no external displays connected), but my
internal display was zoomed in too far.

xrandr appeared to report the normal resolution of 1920x1080 for the T480s.
After running `xrandr --output eDP-1 --scale 2x2`, the appearance
looked right, but the display would lag for any terminal but the one
on the left. Re-examining xrandr, it looks like the internal
display was set to 4k resolution?

Trying to see the internal display back to 1920x1080 didn't
appear to change the scaling, but going back to a 1x1 scale at
least fixed the lag, but it's too zoomed in.

### Update on scaling issue

Turns out I had left a test `~/.Xresources` file with DPI scaling set.

```
Xft.dpi: 180
Xft.autohint: 0
Xft.lcdfilter:  lcddefault
Xft.hintstyle:  hintfull
Xft.hinting: 1
Xft.antialias: 1
Xft.rgba: rgb
```
