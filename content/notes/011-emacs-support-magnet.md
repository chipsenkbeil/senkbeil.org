+++
title = "Emacs support Magnet"
slug = "emacs-support-magnet"
description = "Installing Emacs that supports Magnet"
date = "2020-04-30"
categories = [ "misc" ]
tags = [ "emacs", "magnet" ]
+++

If you're using homebrew, you'd normally install the GUI Emacs application via

```
brew cask install emacs
```

The problem is that this installs the standard GNU Emacs leveraging some basic Cocoa GUI, which results in the [Magnet](https://magnet.crowdcafe.com/)
application not being able to snap Emacs to any of its grids. If you look at
the Magnet dropdown with Emacs focused, all of the options will be greyed out.

As described in [this reddit post](https://www.reddit.com/r/emacs/comments/8ez3a9/macos_window_snapping_with_magnetdoesnt_work_on/), there is an Emacs distribution designed specifically for Mac OS X that adds [additional features](https://bitbucket.org/mituharu/emacs-mac/src/f3402395995bf70e50d6e65f841e44d5f9b4603c/README-mac?at=master&fileviewer=file-view-default) through a Carbon port (over Cocoa from default homebrew).

Installing this version can be done via

```
brew cask install railwaycat/emacsmacport/emacs-mac
```

As of writing this note, Emacs 26.3 is installed and works well with Magnet
2.4.5 on Mac OS X 10.15.3.
