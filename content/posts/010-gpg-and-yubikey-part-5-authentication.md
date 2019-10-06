+++
title = "Applying GPG and Yubikey: Part 5 (Authentication)"
slug = "applying-gpg-and-yubikey-part-5-authentication"
date = "2019-10-06"
categories = [ "applying" ]
tags = [ "gpg", "yubikey" ]
+++

As a reminder, you can check out my [overview
post](/posts/applying-gpg-and-yubikey-part-1-overview) if you're curious about
why and in what ways I started using GPG and Yubikey. If you haven't set up
your GPG keys yet, I also talk about a simple flow [in my second
post](/posts/applying-gpg-and-yubikey-part-2-setup).

Today, we're going specifically into using GPG for authentication for SSHing
into remote servers and associating with Github.

### Using my GPG key for authenticating over SSH

One handy use case for GPG keys related to authentication is using a GPG key to
access remote servers over SSH. Rather than using password-based authentication
or SSH public key authentication via `ssh-keygen`, we can leverage a GPG key
with authentication capabilities to connect instead.

The prerequisite is that we need a GPG key with authentication capabilities.
Make sure that you have one by checking your keys and capabilities via `gpg
-k`:

![Output of gpg -k showing keys](/img/post/keys/gpg-keys-list.png)

I've personally switched over my home servers to only allow public key
authentication over SSH and am leveraging my GPG auth subkey rather than the
traditional [SSH key](https://www.ssh.com/ssh/key/) because it enables me to
only manage a single key and I can store my GPG key on external hardware like a
Yubikey in the same manner as my encryption and signing keys.

There are a couple of requirements to plug in a GPG auth key for use via SSH:

1. Add the keygrip of the auth key to __$HOME/.gnupg/sshcontrol__
2. Enable SSH support for the GPG agent
3. Export the SSH auth socket from the GPG agent
4. Copy over the ssh-rsa contents of the GPG auth key to the remote server(s)

#### More Details

Based on [this article](https://opensource.com/article/19/4/gpg-subkeys-ssh)
from April 2019, we need to make ssh aware of GPG auth keys.

As mentioned, the first step is to get the keygrips of auth keys via `gpg -K --with-keygrip` and place them into __$HOME/.gnupg/sshcontrol__.

From there, the second step is to make sure that __gpg-agent__ is configured
with ssh by adding `enable-ssh-support` to __$HOME/.gnupg/gpg-agent.conf__ and
restarting the agent via `gpgconf --kill all`. We can also manually launch the
GPG agent via `gpgconf --launch gpg-agent` if needed.

The third step is to set __SSH_AUTH_SOCK__ to the GPG agent's SSH socket, which
can be done by adding the following export to our Bash - __$HOME/.bashrc__ - or
Zsh - __$HOME/.zshrc__ - config:

```
export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
```

Lastly, the fourth and final step is to add an __ssh-rsa__ public key to the
remote server(s) where we want to use our GPG auth key to connect. This makes
them aware of valid keys to accept incoming requests. We can get the key via
`ssh-add -L`, which should output one or more __ssh-rsa__ public keys based on
our GPG auth key if the agent has been configured correctly and we have
exported __SSH_AUTH_SOCK__.

Copy entire output from `ssh-add -L` to each remote machine's
__$HOME/.ssh/authorized_keys__ file, or alternatively use `ssh-copy-id
<username>@<server>` to smart copy the keys over that do not yet exist.

> I had two keys show up, one with my card number for the yubikey and one
> listed as none. I only added the key that had the card number to my remote
> servers and it worked fine.

### Connecting my GPG auth key with Github for SSH

![Github SSH & GPG keys](/img/post/keys/github-keys.png)

Adding support for Github authentication is very similar to the steps listed
for a remote server that you own with the distinction that we need to copy the
output of `ssh-add -L` to a textbox on Github's website when adding a new SSH
key (our GPG auth key).

![Adding a new SSH key on Github](/img/post/keys/github-add-ssh-key.png)

## What's next?

In [the next post](/posts/applying-gpg-and-yubikey-part-6-setting-up-yubikeys), I'll be explaining how configure a Yubikey to host GPG subkeys for encryption, signing, and authentication as well as my process to maintain a single set of keys across multiple Yubikeys for different computers and other devices.
