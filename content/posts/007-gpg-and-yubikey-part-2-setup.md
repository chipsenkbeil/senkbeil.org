+++
title = "Applying GPG and Yubikey: Part 2 (Setup Primary GPG Key)"
slug = "applying-gpg-and-yubikey-part-2-setup-primary-gpg-key"
date = "2019-08-16"
lastmod = "2019-12-10"
categories = [ "applying" ]
tags = [ "gpg", "yubikey" ]
+++

If you haven't read [my overview
post](/posts/applying-gpg-and-yubikey-part-1-overview), feel free to check it
out to get an idea of why and how I started using GPG and Yubikey.

Today we'll be diving into how to set up a new master GPG key and configure it
for use with the [pass](https://passwordstore.org/) utility.

## Setting up a primary GPG key

Although I knew I had an old key floating around from previous use, I wanted to
start from scratch. From reading a variety of guides and documentation online, I knew that I wanted to create a new 4096-bit long RSA key. The time needed generate such a key on modern hardware is negligible and provides the maximum protection offered today. Luckily, the GPG interface has improved drastically since I first used it, so this process - and all of the processes I'll discuss later - has been relatively painless.

### Step 1: Generate a Full Key

For the master key, I went with RSA and setting my own capabilities as I need
more beyond signing. RSA seems to be one of the more common recommendations
(over DSA) these days.

```
gpg --generate-full-key
```

```
Please select what kind of key you want:
   (1) RSA and RSA (default)
   (2) DSA and Elgamal
   (3) DSA (sign only)
   (4) RSA (sign only)
   (7) DSA (set your own capabilities)
   (8) RSA (set your own capabilities)
   (9) ECC and ECC
  (10) ECC (sign only)
  (11) ECC (set your own capabilities)
  (13) Existing key
Your selection? 8
```

### Step 2: Assign Capabilities

I left the capabilities as provided with the intention of creating subkeys
later that represent the actual capabilities. __Certify__ is a unique
capability to your master key that enables it to approve (sign?) other keys
that you want to trust. It can also create subkeys which we'll talk about in a
later post.

Encryption is the main capability we need for password (and other) encryption.
Sign is handy to add ownership to emails and commits (again, discussed in later posts). Authentication enables use of a key for entry into servers via SSH and other means.

```
Possible actions for a RSA key: Sign Certify Encrypt Authenticate
Current allowed actions: Sign Certify Encrypt

   (S) Toggle the sign capability
   (E) Toggle the encrypt capability
   (A) Toggle the authenticate capability
   (Q) Finished

Your selection? q
```

### Step 3: Set key bit length

The more bits you have in your key, the harder it is to crack. These days, it
seems that a minimum of 2048 bits is recommended, but many folks I know choose
to use the maximum supported length of 4096 bits. The needed computation and
time required to generate the key is negligible with modern hardware; so, I
went with 4096 bits.

```
RSA keys may be between 1024 and 4096 bits long.
What keysize do you want? (2048) 4096
Requested keysize is 4096 bits
```

### Step 4: Specify key expiration

For my primary key, I wanted one that would not expire. It will be serving as a
form of identification for me going forward. Separately, when we create
subkeys, many of those will be set to expire. I'll be storing my primary key
offline and am not concerned about having it expire.

```
Please specify how long the key should be valid.
         0 = key does not expire
      <n>  = key expires in n days
      <n>w = key expires in n weeks
      <n>m = key expires in n months
      <n>y = key expires in n years
Key is valid for? (0)
Key does not expire at all
Is this correct? (y/N) y
```

### Step 5: Assign an identity to your key

You can assign one or more identities to a key and I provided a unique email
address of mine. As you'll see later, I'll proceed to add many other identities
including old school email addresses, gmail accounts, and more.

I've used identification myself for two purposes: signing my commits - sites
like Github require your key to have an identity whose email address matches
that of a verified email on the site - and use with key lookup for encryption
recipients (versus using a specific key's long id).

```
GnuPG needs to construct a user ID to identify your key.

Real name: Chip Senkbeil
Email address: chip@senkbeil.org
Comment: Personal [Senkbeil]
You selected this USER-ID:
    "Chip Senkbeil (Personal [Senkbeil]) <chip@senkbeil.org>"
```

### Step 6: Verify key was created

> I have a couple of configuration changes in my `gpg.conf` such as `keyid-format 0xlong` which may alter the output below from what you would see.

Once I had finished creating my key, I could check out some information about
it via `gpg -k`:

```
pub   rsa4096/0x6CA6A08DBA640677 2019-03-01 [SC]
      2C8160E6AF1166154CDAED266CA6A08DBA640677
uid                   [ultimate] Chip Senkbeil (Personal [Senkbeil]) <chip@senkbeil.org>
sub   rsa4096/0x588B4B090695884C 2019-03-01 [E]
```

That lists the public keys for my newly created primary key __and__ subkey.
Notice how the sign and certify permissions are associated with the primary key
(marked pub) and encryption is placed in a subkey (marked sub).

You can also view your private keys in a similar manner via `gpg -K`, which can
also show information about where a key is located as well as whether or not it
is available, which we'll get into when we set up our subkeys for use with
Yubikey.

```
/home/chipsenkbeil/.gnupg/pubring.kbx
-------------------------------------
sec   rsa4096/0x6CA6A08DBA640677 2019-03-01 [SC]
      2C8160E6AF1166154CDAED266CA6A08DBA640677
uid                   [ultimate] Chip Senkbeil (Personal [Senkbeil]) <chip@senkbeil.org>
ssb   rsa4096/0x588B4B090695884C 2019-03-01 [E]
```

### (Optional) Step 7: Create additional subkeys

> Subkeys are incredibly handy for separating responsibilities and limiting
> the impact to your web of trust for your identity if a key is compromised
> or stolen. This is an optional step to create new subkeys for signing and
> authentication, which we'll explore further in later posts.

If you look at the output of `gpg -k` after creating your first primary key,
you should notice two different keys, primary labeled with *pub* and each
subkey with *sub*. Each key will have its capabilities listed next to its ID,
one capital letter per capability. In my case, I had the primary key produced
with Sign (S) and Certify (C) capabilities and a *subkey* with Encrypt (E)
capability.

I would prefer to have one subkey per responsibility so that I can store my
primary key offline and only use it when producing new subkeys, revoking
subkeys, adding new UIDs, or any other key-modification responsibility.
Originally, I tried having a single subkey with encrypt, sign, and authenticate
capabilities; however, this is a discouraged practice and caused issues later.
Instead, we'll be creating an individual subkey per capability.

Given that we already have a subkey for the encrypt capability, we only need to
create two subkeys: one for sign and one for authenticate. To start, we need to
open an interactive menu via `gpg --edit-key 6CA6A08DBA640677`. You may need to
include **--expert** to create/modify keys.

> Alternatively, I could have used an UID such as *chip@senkbeil.org* instead of the primary key ID. There are a variety of ways to specify a user id (UID), which are described on the [official documentation page](https://www.gnupg.org/documentation/manuals/gnupg/Specify-a-User-ID.html).

#### (Optional) Step 7.1: Create sign subkey

We start by being in an interactive CLI where we want to run `addkey` to begin
the process of adding a new subkey. This **requires** you to have your primary
key available, it cannot be removed or stubbed.

```
gpg> addkey

# You may need to enter your password for the primary key here
```

Like when creating the primary key, we want to specify capabilities. For the
signing key, this is fairly straightforward using **RSA (sign only)**.

```
Please select what kind of key you want:
   (3) DSA (sign only)
   (4) RSA (sign only)
   (5) Elgamal (encrypt only)
   (6) RSA (encrypt only)
   (7) DSA (set your own capabilities)
   (8) RSA (set your own capabilities)
Your selection? 4
```

Similarly, we need to specify a bit length. I've been using the max of 4096 as
my Yubikey supports that length key. If you plan to combine your GPG keys with
your Yubikey(s), make sure to check the maximum length it supports!

```
RSA keys may be between 1024 and 4096 bits long.
What keysize do you want? (2048) 4096
```

Lastly, we need to specify an expiration for a key. Unlike encryption, I want
to cause my sign (and authenticate) keys to expire after five years.

```
Please specify how long the key should be valid.
         0 = key does not expire
      <n>  = key expires in n days
      <n>w = key expires in n weeks
      <n>m = key expires in n months
      <n>y = key expires in n years
Key is valid for? (0) 5y
```

#### (Optional) Step 7.2: Create authenticate subkey

We go through a similar flow for the authenticate key, except we need to
specify our own capabilities via **RSA (set your own capabilities)**.

```
gpg> addkey

# You may need to enter your password for the primary key here

Please select what kind of key you want:
   (3) DSA (sign only)
   (4) RSA (sign only)
   (5) Elgamal (encrypt only)
   (6) RSA (encrypt only)
   (7) DSA (set your own capabilities)
   (8) RSA (set your own capabilities)
Your selection? 8
```

By default, sign and encrypt capabilities will be selected. I toggled both of
those off first and then added authenticate.

```
Possible actions for a RSA key: Sign Encrypt Authenticate
Current allowed actions: Sign Encrypt

   (S) Toggle the sign capability
   (E) Toggle the encrypt capability
   (A) Toggle the authenticate capability
   (Q) Finished

Your selection? S
Your selection? E
Your selection? A
```

Lastly, we want to specify our bit length and expiration period. I followed the
same configuration as with the sign subkey.

```
RSA keys may be between 1024 and 4096 bits long.
What keysize do you want? (2048) 4096

Please specify how long the key should be valid.
         0 = key does not expire
      <n>  = key expires in n days
      <n>w = key expires in n weeks
      <n>m = key expires in n months
      <n>y = key expires in n years
Key is valid for? (0) 5y
```

## What's next?

In [the next post](/posts/applying-gpg-and-yubikey-part-3-encryption), I'll be explaining how I set up [pass](https://passwordstore.org/) and [neomutt](https://neomutt.org/) for encrypting passwords and email respectively.
