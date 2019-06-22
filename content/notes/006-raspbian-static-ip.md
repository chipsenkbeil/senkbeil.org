+++
title = "Raspbian Static IP"
slug = "raspbian-static-ip"
description = "Quick steps to set a static IP address for Raspbian in 2019"
date = "2019-06-22"
categories = [ "config" ]
tags = [ "raspbian" ]
+++

The main changes need to occur in `/etc/dhcpcd.conf`.

### Find Interface Name

Before editing that file, we need to look up our ethernet interface name.
This used to be something easy like __eth0__, but Debian appears to have
[changed interface names](https://wiki.debian.org/NetworkConfiguration#Predictable_Network_Interface_Names). Run `ifconfig` to see Debian's current interfaces. With the Raspberry Pi 3 B+, there will also be a wifi interface shown as below:

```

enxb827ebb61344: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
        ether b8:27:eb:b6:13:44  txqueuelen 1000  (Ethernet)
        RX packets 24867  bytes 5952214 (5.6 MiB)
        RX errors 1  dropped 350  overruns 0  frame 0
        TX packets 2884  bytes 222449 (217.2 KiB)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0

lo: flags=73<UP,LOOPBACK,RUNNING>  mtu 65536
        inet 127.0.0.1  netmask 255.0.0.0
        inet6 ::1  prefixlen 128  scopeid 0x10<host>
        loop  txqueuelen 1000  (Local Loopback)
        RX packets 0  bytes 0 (0.0 B)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 0  bytes 0 (0.0 B)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0

wlan0: flags=4099<UP,BROADCAST,MULTICAST>  mtu 1500
        ether b8:27:eb:e3:46:11  txqueuelen 1000  (Ethernet)
        RX packets 0  bytes 0 (0.0 B)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 0  bytes 0 (0.0 B)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0
```

Notice __enxb827ebb61344__, the ridiculously ugly interface name that we'll
need when setting our static IP.

### Updating /etc/dhcpcd.conf

With the interface name for ethernet written down, we can open up
`/etc/dhcpcd.conf`. There may already be a section for configuring a static IP address. Either way, we'll want something like the following:

```
# Static IP for raspberry pi (192.168.1.10)
interface enxb827ebb61344
static ip_address=192.168.1.10/24
static routers=192.168.1.1
static domain_name_servers=192.168.1.1
```

This should set the Raspbian to have an IP address of __192.168.1.10__,
pointing to our router at __192.168.1.1__.

Make sure to reboot afterwords.
