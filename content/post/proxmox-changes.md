+++
title = "Prommox Changes"
description = "Writeup about changes and additions made to proxmox installation"
date = "2018-01-14"
tags = [ "proxmox" ]
categories = [ "config" ]
+++

### Generating Let's Encrypt certs ###

https://pve.proxmox.com/wiki/HTTPS_Certificate_Configuration_(Version_4.x_and_newer)#Let.27s_Encrypt_using_acme.sh

### Supporting port 80 & 443 ###

By default, proxmox looks for traffic only on port 8006. Based on my readings
online, forcefully changing the port - which is now hardcoded - can cause a lot
of problems. Instead, the most recent and successful recommendation has been to
use _nginx_ to redirect traffic on port 80 and 443 to port 8006. Below is
the configuration created at `/etc/nginx/conf.d/proxmox.conf` after clearing
the files `/etc/nginx/conf.d/default` and `/etc/nginx/site-enabled/default`.

```
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

    # For use with local cert
    # ssl_certificate /etc/pve/local/pve-ssl.pem;
    # ssl_certificate_key /etc/pve/local/pve-ssl.key;

    # For use with acme.sh (Let's Encrypt)
    ssl_certificate /etc/pve/local/pveproxy-ssl.pem;
    ssl_certificate_key /etc/pve/local/pveproxy-ssl.key;

    proxy_redirect off;

    location / {
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_Header Connection "upgrade";
        proxy_pass https://localhost:8006;
        proxy_buffering off;
        client_max_body_size 0;
        proxy_connect_timeout 3600s;
        proxy_read_timeout 3600s;
        proxy_send_timeout 3600s;
        send_timeout 3600s;
    }
}
```

### Set local root to full SSD and lvm-thin to extra HDD ###

TODO: Figure out.

