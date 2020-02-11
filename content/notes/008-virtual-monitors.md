+++
title = "Linux Virtual Monitors with xrandr"
slug = "linux-virtual-monitors-with-xrandr"
description = "How and why to configure virtual monitors with xrandr"
date = "2019-08-14"
lastmod = "2019-12-15"
categories = [ "config" ]
tags = [ "xrandr" ]
+++

I recently learned that you can configure virtual monitors with xrandr. There
are two different ways to use this: treat multiple physical monitors as
one giant virtual monitor or treat one physical monitor as multiple
virtual monitors.

> Note that this requires xrandr 1.5.0 or higher, which introduces setmonitor
> as an option in the CLI.

## Why do I want to do this?

My primary interest here is to split a super widescreen monitor like the
[Dell 49" UltraSharp Curved Monitor (U4919DW)](https://www.dell.com/en-us/shop/dell-ultrasharp-49-curved-monitor-u4919dw/apd/210-arnw/monitors-monitor-accessories) as multiple separate displays. I like the way that dwm breaks up monitors into multiple spaces and when I have two or three separate monitors I normally use a center monitor for focused work with the side monitors containing music, calendar, and chat.

The idea here is to keep the same setup, but leverage an ultrawide
monitor rather than multiple physical monitors that require an eGPU to drive
from a laptop rather than plugging the laptop in directly.

## How do I do this?

[This post](https://askubuntu.com/a/998435) highlighted a means to do this
with xrandr 1.5+ virtual monitors.

Leveraging **xrandr** to print out your display information, you can create
new virtual monitors using `xrandr --setmonitor`.

On my laptop, the output of `xrandr` yielded:

```
Screen 0: minimum 320 x 200, current 1920 x 1080, maximum 8192 x 8192
eDP-1 connected primary 1920x1080+0+0 (normal left inverted right x axis y axis) 309mm x 173mm
   1920x1080     60.01*+  59.97    59.96    59.93
   1680x1050     59.95    59.88
   1400x1050     59.98
   1600x900      59.99    59.94    59.95    59.82
   ...
DP-1 disconnected (normal left inverted right x axis y axis)
HDMI-1 disconnected (normal left inverted right x axis y axis)
DP-2 disconnected (normal left inverted right x axis y axis)
HDMI-2 disconnected (normal left inverted right x axis y axis)
```

To split into left and right virtual monitors, I ran:

```
xrandr --setmonitor eDP-1-1 960/154x1080/173+0+0 eDP-1
xrandr --setmonitor eDP-1-2 960/155x1080/173+960+0 none
```

Upon issuing the first command, the left side of my monitor became its
own entity and the right side was blank (as if unplugged). The second
command added a second monitor (picked up by dwm).

I was able to remove both monitors can get back to normal by running:

```
xrandr --delmonitor eDP-1-2
xrandr --delmonitor eDP-1-1
```

The post mentioned above stated that the following commands were needed
for xrandr to refresh the changes, but they weren't required for me on a
T480s with Fedora 30:

```
xrandr --fb 1921x1080
xrandr --fb 1920x1080
```
