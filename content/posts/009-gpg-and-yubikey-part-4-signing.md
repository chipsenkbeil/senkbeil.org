+++
title = "Applying GPG and Yubikey: Part 4 (Signing)"
slug = "applying-gpg-and-yubikey-part-4-signing"
date = "2019-08-26"
categories = [ "applying" ]
tags = [ "gpg", "yubikey" ]
draft = true
+++

### Using my GPG key for email signing

Mention neomutt
Mention notmuch

### Using my GPG key for signing commits

I'll admit that until Github [announced support for displaying verified
commits](https://github.blog/2016-04-05-gpg-signature-verification/), I did not
know that you could sign git commits. Even after that announcement, signing
commits was not something that I planned to seek out to accomplish.

Setting up the signing process is actually very easy. For git, you need to
create a __.gitconfig__ file in your home directory. From there, add your
signing key

```
[user]
    name = Chip Senkbeil
    email = chip@senkbeil.org
    signingkey = 0x6CA6A08DBA640677
```

You need to make sure that whatever signing key you use has an ID whose email
address matches that of the email you provide in your git config. Also, just
like with encryption, you [aren't restricted to using a key's ID](https://www.gnupg.org/documentation/manuals/gnupg/Specify-a-User-ID.html). In my actualy config, I've replaced my signing key ID with my email address of `chip@senkbeil.org`.

Out of the box, I can now sign commits explicitly using using `git commit -S`
to sign each commit as you make it. For me, I would prefer automatic signing of
all commits given that I plan to have my key available on any computer I use.
To that end, I added an extra setting to __.gitconfig__ to automatically sign
all commits:

```
[commit]
    gpgsign = true
```

What's neat is that other version control systems like Mercurial also support
signing commits. I just needed to enable the [gpg extension](https://www.mercurial-scm.org/wiki/GpgExtension) in my __.hgrc__, specify the GPG command, and provide a signing key.

```
[extensions]
gpg=

[gpg]
cmd=gpg
key=0x6CA6A08DBA640677
```

### Using my GPG key for authenticating over SSH

Mention SSH_AUTH_SOCK
Mention ssh-add -L
Mention ssh-copy-id

### Connecting my GPG key with Github

Mention SSH & GPG available on Github
Mention UI for adding keys (with picture)

### Dealing with subkeys

When inspecting my newly-created key, I noticed that the encryption
functionality belonged to what I later learned was a subkey. My primary key had
signing and certification capabilities.


Mention use of subkeys to keep separate from primary key
Mention creating 4096 with individual capabilities
- Point out issue encountered when gave one subkey multiple capabilities

### Moving my GPG key to YubiKey

Mention making stubs with >
Mention backing up directory (not just exporting keys) to repeat on multiple
keys
Mention old approach with multiple subkeys and wrong YubiKey?
- Can point out the approach for swapping YubiKey

### Using GPG key on mobile

Mention YubiKey NFC, Password Store app, and OpenKeychain app

### Revoking my GPG key

Mention old process of making unique subkey for each YubiKey
Mention process of revoking

## Conclusion

TODO... what should be put here?

What is it?

Why did I need it?

What did I do?

Conclusion

When adding new keys at the same time to GPG (recipients) or passwordstore, I needed to add an exclamation mark to the end. E.g. 0xDEADBEEF! in order to force encryption with that key and allow multiple keys as options.

See https://security.stackexchange.com/questions/181551/create-backup-yubikey-with-identical-pgp-keys
for details. I may have a different approach using a SINGLE set of subkeys and
duplicating if I can get it to have a different card id on each machine.

NOTE: Originally, I was using manual subkey IDs to encrypt. With pass, if you
provide the email address for the key containing the subkeys (for me
chip@senkbeil.org), then pass will pull all of the encryption subkeys to use
for you. Need to test if the exclamation mark is still needed.

Need to provide the option --limit-card-insert-tries=1 to disable the dialog to insert a key. Ideally, I already have the key I need, and it's REALLY annoying when I have different encryption keys on multiple smartcards and I get multiple prompts to insert a smart card. So far, this option isn't working like indicated. I'm only 2.0.10 and the latest is 2.0.15, so wondering if a bug.

NOTE: Turns out the functionality was removed (by accident?) and I've written a
note about it in my gpg.conf. Should get a patch out to fix it for gpg.

When getting issue about invalid ID and no secret key when decrypting from GPG on Yubikey (even though encrypt worked), it was because I had a single key with SEC (sign, encrypt/decrypt, auth). See https://marc.info/?l=gnupg-users&m=155057187801474&w=2 for details, but just creating a subkey dedicated to encrypt/decrypt fixed that issue.

On Android phone, needed to go to Settings > Connections > NFC to enable it.

When using my keys on new computers, I still need to import my public keys.
They are hosted on keybase.io, ubuntu server, and more.

```
curl https://keybase.io/senkwich/pgp_keys.asc | gpg --import
```

Can add url to Yubikeys to auto pull the public key? Yes, but easier with
command instead of needing to do `gpg --edit-card` followed by `fetch`

For signing, currently using `chip@senkbeil.org`, which I believe will
default to the most recently used subkey, but not sure. So far, it seems to
be working. I did notice a warning about trust on other laptops that didn't
originate the private master key. They show the key as `[unknown]` instead
of `[ultimate]` for trust level. Need to go in and do `gpg --edit-card`
followed by `trust` and select level 5 (full trust) since this is my own
key.

NOTE: Not selecting most recently used subkey.

## Updating keyring to indicate most subkeys are offline

My keyring on the laptop that I've been using to make subkeys for yubikey

```
sec#  rsa4096/0x6CA6A08DBA640677 2019-03-01 [SC]
      2C8160E6AF1166154CDAED266CA6A08DBA640677
uid                   [ultimate] Chip Senkbeil (My mail & pass key) <chip@senkbeil.org>
ssb>  rsa4096/0x588B4B090695884C 2019-03-01 [E]
ssb>  rsa4096/0x8A6B3DB2C23EB74B 2019-05-08 [E]
ssb>  rsa4096/0x95B67753BA414327 2019-05-08 [E]
ssb>  rsa4096/0x231C4CB425985243 2019-05-28 [S] [expires: 2024-05-26]
ssb>  rsa4096/0x1F3D585E398D11B1 2019-05-28 [S] [expires: 2024-05-26]
ssb>  rsa4096/0x5487424ABA6BDDDB 2019-05-28 [S] [expires: 2024-05-26]
ssb>  rsa4096/0x68F5987A509841B2 2019-05-28 [A] [expires: 2024-05-26]
ssb>  rsa4096/0x70B8AA34DA9D2413 2019-05-28 [A] [expires: 2024-05-26]
ssb>  rsa4096/0xDD69ABE5B8BCF75C 2019-05-28 [A] [expires: 2024-05-26]
ssb>  rsa4096/0xD2A7E4F93EE05063 2019-06-01 [E]
ssb>  rsa4096/0xBD37FFFCCF094200 2019-06-01 [E]
ssb>  rsa4096/0xA8A1328E9E32C17D 2019-06-01 [S] [expires: 2024-05-30]
ssb>  rsa4096/0x7C55D59BE4B5A22F 2019-06-01 [S] [expires: 2024-05-30]
ssb>  rsa4096/0xD34B040C5D45D107 2019-06-01 [A] [expires: 2024-05-30]
ssb>  rsa4096/0x27ACC8B2AA43159B 2019-06-01 [A] [expires: 2024-05-30]
```

`#` pound sign means that the key is offline (unavailable). I removed my
master key from the machine using `gpg-connect-agent "DELETE_KEY
<KEYGRIP>"` followed by `/bye` to exit.

Got keygrips using `gpg2 --list-secret-keys --with-keygrip`

Thought is that gpg is picking the wrong subkey because it think all of them
are available right now. I only want it to think a specific subkey is
available. To do that, need to go through and mark the stubs as offline.
Before, when all were offline, inserting a smart card and using `gpg
--card-status` refreshed and changed `#` to `>`.

Deleting a stub using `DELETE_KEY <KEYGRIP>` and then refreshing with `gpg
--card-status` does indeed return `#` to `>`.

Annoyance is that doing `gpg-connect-agent "DELETE_KEY <KEYGRIP> /bye"` still
leaves us in the gpg-connect-agent mode until we hit enter. How to leave? Turns out, need to do the bye logic outside via `gpg-connect-agent "DELETE_KEY <KEYGRIP>" /bye`

Can use `gpg --list-secret-keys --with-keygrip "fingerprint"` to only get
keygrips for my specific key.

NOTE: Making all keys offline except for subkey that is available fixes
signing problem, but for some reason does not fix encryption. Still need
exclamation mark on all recipients for pass tool.

## Using auth key with github.com

Based on [this article](https://opensource.com/article/19/4/gpg-subkeys-ssh)
from April 2019, need to make ssh aware of gpg auth keys.

Get the keygrips of auth keys via `gpg -K --with-keygrip` and place into
`$HOME/.gnupg/sshcontrol`.

Make sure that gpg-agent is configured with ssh by adding `enable-ssh-support`
to `$HOME/.gnupg/gpg-agent.conf` and restarting the agent via `gpgconf --kill
all`. Can manually launch via `gpgconf --launch gpg-agent` if needed.

Add this export to `.bashrc` or `.zshrc`:

```
export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
```

Get ssh-rsa public key to provide to github via `ssh-add -L`. The above
resolved the "no identity" issue I was encountering earlier.

I had two keys show up, one with my card number for the yubikey and one
listed as none. I had added all five of my auth keys (one per yubikey) to
the sshcontrol file. I only added the key that had the card number to
github and it worked fine.

### Using auth key for ssh to remote machines

Follow the setup for github to get ssh to detect auth keys.

Copy entire output from `ssh-add -L` to remote machine's
`$HOME/.ssh/authorized_keys` file, or alternatively use `ssh-copy-id
<username>@<server>` to smart copy the keys over that do not yet exist.

After that, sshing into the machine works just fine for me.

### Revoking keys

Can have a revoke cert, or if using subkeys can revoke using master key, which
is what I did for old approach.

When others pull public keys for you and list (or you list private keys), the
revoked keys will not be shown (less noise).

Revoked keys will be shown when doing `gpg --edit-key <KEY>`, which is
annoying. Can delete keys from keyring for them to not be shown, but pulling
down keys from keyserver will make them appear again.

### neomutt & notmuch

Can self encrypt to read sent mail for neomutt

Need to determine settings for neomutt to encrypt. We don't want to
auto-encrypt, do we? Things like gmail and outlook will struggle.

notmuch can use gpg keys to decrypt if index.decrypt set to nostash or true.
Default is auto, which only uses stashed session keys.

Given we have our key stored in a yubikey and password protected,
fine with nostash.
