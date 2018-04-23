+++
date = "2016-02-17T07:49:30-06:00"
title = "Fix for XMonad with XMobar"
slug = "fix-for-xmonad-with-xmobar"
tags = [ "bug fix" ]
categories = [ "snippet" ]
+++

When I updated XMonad late last year (2015), I noticed a bug where any
application that I opened on my first workspace would cover XMobar.

    E.g. Opening a terminal or Vivaldi took up the entire screen.

The solution I found was, conveniently, located in a [post on the ArchLinux
forum](https://bbs.archlinux.org/viewtopic.php?id=206890).

Essentially, you just need to add a `handleEventHook` with `docksEventHook`
and `handleEventHook defaultConfig`.

```haskell
-- My overall config that is used elsewhere
myConfig = defaultConfig
    { manageHook = manageDocks <+> manageHook defaultConfig
    , layoutHook = avoidStruts $ layoutHook defaultConfig
    , handleEventHook = mconcat
                        [ docksEventHook
                        , handleEventHook defaultConfig ]
    , startupHook = setWMName "LG3D"
    , terminal = "urxvtcd"
    , modMask = mod1Mask
    , borderWidth = 1
    , focusedBorderColor = "blue"
    }
```

