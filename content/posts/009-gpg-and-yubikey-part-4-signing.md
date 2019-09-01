+++
title = "Applying GPG and Yubikey: Part 4 (Signing)"
slug = "applying-gpg-and-yubikey-part-4-signing"
date = "2019-09-02"
categories = [ "applying" ]
tags = [ "gpg", "yubikey" ]
+++

As a reminder, you can check out [overview
post](/posts/applying-gpg-and-yubikey-part-1-overview) if you're curious about
why and in what ways I started using GPG and Yubikey. If you haven't set up
your GPG keys yet, I also talk about a simple flow [in my second
post](/posts/applying-gpg-and-yubikey-part-2-setup). Finally, the email signing
section expects you to have already set up encryption, so you should really
check out [my third post](/posts/applying-gpg-and-yubikey-part-3-encryption)
regarding encryption setup with neomutt.

Today, we're going specifically into using GPG for signing email and git
commits.

### Using my GPG key for email signing

Adding signing capabilities is a matter of specifying a couple of extra
settings regarding when to sign and with what key. To make it clear how signing
works in collaboration with encryption, I'm including my full neomutt
configuration file. Relevant settings include __crypt_autosign__,
__crypt_replysign__, and __pgp_sign_as__ to distinguish the signing key from
the encryption key.

```bash
# << CRYPTO: GENERAL CONFIG >>

# Use GPGME backend instead of classic code
set crypt_use_gpgme = "yes"

# Attempt to cryptographically sign outgoing messages
set crypt_autosign = "yes"

# Always attempt to veryify email signatures
# NOTE: Set by default
set crypt_verify_sig = "yes"

# Automatically sign replies to signed emails
set crypt_replysign = "yes"

# Automatically encrypt replies to encrypted emails
# NOTE: Set by default
set crypt_replyencrypt = "yes"

# Automatically sign replies to encrypted emails, gets
# around issues with pure replysign
set crypt_replysignencrypted = "yes"

# Auto encrypt out outgoing messages
# NOTE: Will ALWAYS try to encrypt even if no keys are available
#set crypt_autoencrypt = "yes"

# Only encrypt if all recipients are found in public key
set crypt_opportunistic_encrypt = "yes"

# << PGP: GENERAL CONFIG >>

# Use a gpg-agent for private key password prompts
# NOTE: Set by default because GnuPG 2.1+ requires it
set pgp_use_gpg_agent = "yes"

# Check status of gpg commands using file descriptor output from
# decrypt and decode commands
# NOTE: Set by default
set pgp_check_gpg_decrypt_status_fd = "yes"

# << PGP: SELF ENCRYPTION CONFIG >>

# When encrypting email, always include own key to be able to read sent mail
set pgp_self_encrypt = "yes"

# Set the key to use for encryption/decryption of email
set pgp_default_key = "588B4B090695884C"

# Set the key to use for signing email
set pgp_sign_as = "6CA6A08DBA640677"
```

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
like with encryption, you [aren't restricted to using a key's ID](https://www.gnupg.org/documentation/manuals/gnupg/Specify-a-User-ID.html). In my actual config, I've replaced my signing key ID with my email address of `chip@senkbeil.org`.

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

## What's next?

In [the next post](/posts/applying-gpg-and-yubikey-part-5-authentication), I'll be explaining how to use GPG for authentication, both to submit commits to Github as well as log into remote servers in a more secure manner.
