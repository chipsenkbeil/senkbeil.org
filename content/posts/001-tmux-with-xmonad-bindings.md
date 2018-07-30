+++
title = "tmux with XMonad Bindings"
slug = "tmux-with-xmonad-bindings"
description = "Writeup about brief work on XMonad-like key bindings for tmux."
date = "2013-12-24"
categories = [ "tool" ]
tags = [ "tmux", "xmonad" ]
+++

### The Reason ###

I've been playing around with `tmux` a lot lately and have come to like it
quite a lot for the panes and windows - something I used quite a lot with my
XMonad setup on my old Fujitsu laptop. The panes act as my individual
terminals with which I can write code, read documentation, chat on IRC (using
`weechat` or `irssi`), play music, etc. In other words, I do quite a lot from
within terminals and being able to split up a terminal into panes (like XMonad
launching tiled terminals) is quite nice. Furthermore, treating the windows
as my workspaces lets me quickly organize myself just like with XMonad.

However, the main issue I have found with tmux is with its keyboard bindings.
Everything in tmux is bound to a prefix (Ctrl-b) followed by a single keystroke
or multiple keystrokes. For instance, splitting a window into two horizontal
panes is the sequence `Ctrl-b "` and splitting it horizontally is `Ctrl-b %`.
I pride myself in being able to pick up things like this quickly, but my mind
continued to nag me about the need of a prefix as well as the use of keys like
double quotes and percent. I was used to XMonad, where creating a new pane
involved a single `Mod-Shift-Enter` and navigating between tiles was a simple
`Mod-Tab`. Because of this, I began to look into ways to rebind tmux keys to
be more like XMonad.

### The Process ###

tmux provides multiple ways to rebind keys and perform startup actions. The
first is to execute the actions from the terminal:

```raw
tmux bind-key d kill-pane
```

Another option is to perform the task within a running tmux instance by
entering `Ctrl-b :`, which enters a command mode for you to enter tmux actions.

Of course, these methods were not what I needed. What I discovered was that
tmux could source a file to get its bindings. You could have `.tmux.conf`
within your home directory or use

```raw
tmux source my_tmux.conf
```

For me, I began to work with the default `.tmux.conf` file. Keybindings were
easy to rebind using `bind-key` and `unbind-key`. For instance, if I wanted
to bind the space key to change the layout - XMonad uses `Mod-Space` by
default - I would use the following:

```raw
bind-key Space next-layout
```

However, a simple `bind-key` does not remove the prefix! This means that the
above would actually be `Ctrl-b Space` as the combination. Luckily, tmux
provides a way to avoid the prefix when performing actions. The `-n` switch
indicates that no prefix should be used.

```raw
bind-key -n C-Space next-layout
```

The above indicates that the series of keystrokes `Ctrl-Space` should change
the layout used in tmux, no prefix needed.

### The Issue ###

The issue I discovered was that modifier keys - Control, Shift, Function, Alt -
were not fully supported in tmux. In fact, modifier keys are not fully
supported in a lot of applications. Instead, you see certain keycodes appear
when a modifier key is used in combination with a normal key. If you execute
`xmodmap` in your terminal, you should get a list of modifier keys in your
computer. Entering `xmodmap -pk` into your terminal yields the actual table
containing the representations of each key without modifiers, with the shift
key, with the mode switch key, with the shift and mode switch keys, with the
alt key, and with the alt and shift keys. If you print this table, you'll
notice that quite a few keys do not have bindings for shift/mode switch keys.

Furthermore, after looking at tmux's source, it appears that only certain keys
are checked for modifiers before passing the keystroke to the application
running within tmux. Because of this, I cannot use a setup like 
`Ctrl-Shift-Return` for creating a new terminal tile using standard tmux.

### The Potential Solution ###

At least, I did not believe that I could. I discovered that tmux provided even
more functionality through the ability to not only launch shell programs but
also check the return status of said programs!

```raw
# Run command if system is Mac OS X
if-shell 'test `uname` == "DARWIN"' <COMMAND> [OPTIONAL COMMAND]
```

Because of this ability, I thought about having a small program that could be
executed to indicate whether modifier keys like control and shift were
currently being pressed down. Returning success indicates they were and
returning failure indicates they were not.

The challenge appeared when I realized that modifier keys were mostly unable
to be tracked in this manner. tmux itself was not at fault for this limitation;
so, I had to dig deeper to find out how to retrieve this bindings. I had seen
some utilities that could detect shift and control key presses, but they were
bound in the X11 system, which I did not want to impose as a restriction for my
setup. In fact, my hope was that this could be run very easily without an X11
system. Furthermore, as a new owner of a Macbook Air - Linux will be put on it
soon enough - I wanted this to be able to work on OS X as well.

### The Mac OS X Solution ###

Cocoa provides the functionality to directly check if modifier keys are
pressed, which is incredibly useful. So, I simply wrote a small Cocoa
application that returns success based on the state of modifier keys. The
documentation indicates that Mac OS X v10.6+ is needed to use this 
functionality; so, this means my solution will only work for Snow Leopard or
higher (sorry Leopard and Tiger).

You can find the small program bundled with the main project
[here](/software/tmux-xmonad-bindings/).

### The Linux Solution ###

This took a little digging before I realized that I needed to access the
keyboard interface directly, rather than accessing information from a
program. This meant accessing `/dev/my_keyboard_interface`, which would vary
from computer to computer.

I wrote a small C program to demonstrate this functionality
[here](/software/keyboard-state/).

Unfortunately, after joining IBM in January of 2014, I was not able to
continue pursuing this project.

### The Final Result ###

Overall, the configuration combined with the modifier keys captured by an
external program successfully produced a working replica of XMonad's key
bindings using tmux, giving me a more comfortable layout for moving
panes and navigating.

You can find the project [here](/software/tmux-xmonad-bindings/).

