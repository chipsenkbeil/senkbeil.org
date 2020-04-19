+++
title = "Configuring Calibre Server from CLI"
slug = "configuring-calibre-server-from-cli"
description = "Configuring Calibre Server entirely from the CLI to server my book library"
date = "2020-04-19"
categories = [ "config" ]
tags = [ "calibre" ]
+++

Watching

## Installing on a FreeBSD Jail

Very easy to do on FreeBSD 11.3 via the FreeNAS GUI.

1. Create a new jail and set a specific IPv4 address to host. For me, this
   was 192.168.5.33
2. Enter into a shell within the jail and run `pkg install calibre`

FreeBSD will ask if we want to download and set up the package manager,
which we do. After that, it'll install a lot of packages (Python 3.7,
some Perl, etc.) and then all CLI commands should be available.

## Create your library

I already had a directory full of books comprised of epub, pdf, html, and txt
files on my FreeNAS box. The first step was to import those books into a
calibre library.

If I was using the Calibre GUI, this would be as simple as pressing a
button; however, this is a little different (still easy) when running
purely from a terminal.

1. Add a mount point within the jail to my directory of books (I used the
   GUI)
2. Run [`calibredb add`](https://manual.calibre-ebook.com/generated/en/calibredb.html#adding-from-directories), specifying a new library location, the recurse option, and a directory of books

  ```
  calibredb add --with-library /var/lib/calibre/library -r /mnt/books
  ```

## Build a user database

Running the server internally on my network is fairly easy, but I wanted to
also expose it externally and needed to create a user with
authentication.

Running [`calibre-server --manage-users`](https://manual.calibre-ebook.com/generated/en/calibre-server.html) and specifying a database location will prompt to create a new user and password. The database location will then be created.

```
calibre-server --userdb /var/lib/calibre/users.sqlite --manage-users
```

## Test running the server on port 8080

```
calibre-server --userdb /var/lib/calibre/users.sqlite --enable-auth
/var/lib/calibre/library
```

Accessing via [http://192.168.5.33:8080](http://192.168.5.33:8080).

Should be greeted with a login prompt.

![Login Prompt](/img/post/calibre/calibre-auth.png)

## Configuring jail to auto-start calibre-server

### Write /etc/rc.d/calibre_server

```sh
#!/bin/sh

# PROVIDE: calibre-server

. /etc/rc.subr

name=calibre_server
rcvar=calibre_server_enable

command="/usr/local/bin/calibre-server"
command_args="--userdb /var/lib/calibre/users.sqlite --enable-auth /var/lib/calibre/library"

load_rc_config $name

# DO NOT TOUCH THESE
calibre_server_enable=${calibre_server_enable-"NO"}
pidfile=${calibre_server_pidfile-"/var/run/calibre_server.pid"}

run_rc_command "$1"
```

Verify by running `/etc/rc.d/calibre_server onestart` to see that it
launches. Should still be able to access the website.

### Enable the server in /etc/rc.conf

```conf
# ...

# <At bottom>

# Enable calibre server
calibre_server_enable="YES"
```

Validate by running `/etc/rc.d/calibre_server start` and accessing via http://192.168.5.33:8080

Now, when the jail is restarted, the calibre server should start
automatically.

## Configuring for external access via nginx & letsencrypt

I already have a raspberry pi with nginx and letsencrypt setup. Traffic for
port 80 and 443 go to the pi, which then routes to the appropriate
device on my internal network.

1. Create a new site under `/etc/nginx/sites-enabled/` named **books**

```nginx
server {
  include /etc/nginx/include.d/server-common.conf
  server_name books.senkbeil.org
  location / {
    include /etc/nginx/include.d/location-common.conf
    proxy_pass http://192.168.5.33:8080;
  }
}
```

2. Add a symlink from `/etc/nginx/sites-enabled/books` to
   `/etc/nginx/sites-available/books`

3. Run the **certbot** script for nginx and select the books site

```bash
sudo certbot --nginx
```

```
Which names would you like to activate HTTPS for?
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
1: books.senkbeil.org
2: ...
3: ...
...
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Select the appropriate numbers separated by commas and/or spaces, or leave input
blank to select all options shown (Enter 'c' to cancel): 1
```

```
Please choose whether or not to redirect HTTP traffic to HTTPS, removing HTTP access.
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
1: No redirect - Make no further changes to the webserver configuration.
2: Redirect - Make all requests redirect to secure HTTPS access. Choose this for
new sites, or if you're confident your site works on HTTPS. You can undo this
change by editing your web server's configuration.
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Select the appropriate number [1-2] then [enter] (press 'c' to cancel): 2
```

Should wind up with a config along the lines below which will forward
traffic to port 8080 from 443 externally. I needed to flush my browser cache
as I still had support for http://books.senkbeil.org/ not being redirected
from an earlier test.

```nginx
server {
  include /etc/nginx/include.d/server-common.conf
  server_name books.senkbeil.org
  location / {
    include /etc/nginx/include.d/location-common.conf
    proxy_pass http://192.168.5.33:8080;
  }

  listen 443 ssl; # managed by Certbot
  ssl_certificate /path/to/books.senkbeil.org/fullchain.pem; # managed by Certbot
  ssl_certificate_key /path/to/books.senkbeil.org/privkey.pem; # managed by Certbot
  ssl_dhparam /path/to/ssl-dhparams.pem; # managed by Certbot
}

server {
  if ($host = books.senkbeil.org) {
    return 301 https://$host$request_uri;
  } # managed by Certbot

  server_name books.senkbeil.org;

  listen 80;
  return 404; # managed by Certbot
}
```
