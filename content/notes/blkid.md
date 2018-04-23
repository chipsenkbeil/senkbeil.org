+++
date = "2012-03-07T12:31:47-05:00"
title = "Using blkid to get device information"
slug = "blkid"
tags = [ "utility" ]
categories = [ "snippet" ]
+++

Quite often, I find myself needing to remind myself of devices connected to my
computer so that I know what to type for the pmount program, which is really
handy to have! The program [i]blkid[/i] is capable of doing this; however, I
didn't care for the default output and found myself using this format:

```bash
blkid -o list -c /dev/null
```

![Example of usage](/img/post/blkid.jpg)

What this does is tell the program to output the information in a user-friendly
list of devices through '-o list' and not report previous devices using '-c
/dev/null.'

As you can imagine, this is very annoying to type out each time. It is also
annoying to include 'sudo' in front of it when I am not the root user. The
program will still output some information, but to display everything I want,
it needs root permissions.

So, to make this as painless as possible, I wrote a very small wrapper script
that does this task for me:

```bash
#! /bin/sh

if [[ $UID != 0]]; then
    echo "This script requires root privileges to run:"
    echo "sudo $0 $*"
fi

blkid -o list -c /dev/null
```

Sticking that in the file list_devices.sh, giving it proper permissions for
execution using chmod +x list_devices.sh, and sticking it in my /usr/bin
directory did wonders for me. Hopefully it'll help someone else out there as
well!

