+++
title = "Proxmox Changes"
slug = "proxmox-changes"
description = "Writeup about changes and additions made to proxmox installation"
date = "2018-01-14"
categories = [ "config" ]
tags = [ "proxmox" ]
+++

### Removing subscription notice ###

```bash
sed -i.bak 's/NotFound/Active/g' /usr/share/perl5/PVE/API2/Subscription.pm && systemctl restart pveproxy.service
```

### Generating Let's Encrypt certs ###

https://pve.proxmox.com/wiki/HTTPS_Certificate_Configuration_(Version_4.x_and_newer)#Let.27s_Encrypt_using_acme.sh

### Supporting port 80 & 443 ###

By default, proxmox looks for traffic only on port 8006. Based on my readings
online, forcefully changing the port - which is now hardcoded - can cause a lot
of problems. Instead, the most recent and successful recommendation has been to
use _nginx_ to redirect traffic on port 80 and 443 to port 8006. Below is
the configuration created at `/etc/nginx/conf.d/proxmox.conf` after clearing
the files `/etc/nginx/conf.d/default` and `/etc/nginx/site-enabled/default`.

```nginx
upstream proxmox {
    server "senkbeil.org";
}
 
server {
    listen 80 default_server;
    rewrite ^(.*) https://$host$1 permanent;
}
 
server {
    listen 443;
    server_name _;
    ssl on;
    #ssl_certificate /etc/pve/local/pve-ssl.pem;
    ssl_certificate /etc/pve/local/pveproxy-ssl.pem;
    #ssl_certificate_key /etc/pve/local/pve-ssl.key;
    ssl_certificate_key /etc/pve/local/pveproxy-ssl.key;
    proxy_redirect off;
    location / {
		proxy_http_version 1.1;
		proxy_set_header Upgrade $http_upgrade;
		proxy_set_header Connection "upgrade"; 
		proxy_pass https://localhost:8006;
		proxy_buffering off;
		client_max_body_size 0;
		proxy_connect_timeout  3600s;
		proxy_read_timeout  3600s;
		proxy_send_timeout  3600s;
		send_timeout  3600s;
    }
}
```

### Set local root to full SSD and lvm-thin to extra HDD ###

My situation was that I had my SSD split into a root and data partition
and had nothing on my HDD. To remedy this, I began by removing the
unused data partition via:

```bash
lvremove /dev/pve/data
```

From there, I acquired a list of drives and available space:

```bash
pvs
```

I saw how much space was available on my primary SSD that I wanted
to merge back into the root partition. In my case, 75.79g of space.

```bash
lvresize -L +75.79g /dev/pve/root
```

Finally, I resized the mapped partition:

```bash
resize2fs /dev/mapper/pve-root
```

After that had completed, I wanted to add my HDD as a thin LVM.

```bash
fdisk /dev/sda
```

Deleted all partitions via `d` and then wrote out the update via `w`.

From there, I used `fdisk` on the same disk again with `n` and primary partition 1,
selecting the _Linux LVM_ partition type. While most docs said it would be _8e_, mine
ended up being _31_. I finalized the change via `w`.

After that, I created a physical volume via:

```bash
pvcreate /dev/sda1
```

And then proceeded to extend my extending volume group of pve via:

```bash
vgextend "pve" /dev/sda1
```

Once I had added the new drive to my pve volume group, I could allocate the
rest of the available space to a thin LVM partition called data:

```bash
lvcreate -l 100%FREE -T -n data pve
```

