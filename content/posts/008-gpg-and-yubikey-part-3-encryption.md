+++
title = "Applying GPG and Yubikey: Part 3 (Encryption)"
slug = "applying-gpg-and-yubikey-part-3-encryption"
date = "2019-09-01"
categories = [ "applying" ]
tags = [ "gpg", "yubikey" ]
+++

As a reminder, you can check out [overview
post](/posts/applying-gpg-and-yubikey-part-1-overview) if you're curious
about why and in what ways I started using GPG and Yubikey. If you haven't
set up your GPG keys yet, I also talk about a simple flow [in my second
post](/posts/applying-gpg-and-yubikey-part-2-setup).

Today, we're going specifically into using GPG for encryption and
how to integrate GPG into [pass](https://passwordstore.org/) and
[neomutt](https://neomutt.org/).

## Refresher of current state

At this point, we have our primary key for signing and certifying (SC) other keys.
You should also notice a second key (labelled as a subkey here) that is purely
for encryption (E). We will be using that encryption key for our utilities
today.

```
pub   rsa4096/0x6CA6A08DBA640677 2019-03-01 [SC]
      2C8160E6AF1166154CDAED266CA6A08DBA640677
uid                   [ultimate] Chip Senkbeil (Personal [Senkbeil]) <chip@senkbeil.org>
sub   rsa4096/0x588B4B090695884C 2019-03-01 [E]
```

## Using my GPG key to encrypt and decrypt files

Congratulations! Now that we have a GPG key that has encryption capabilities, w
e can use it to both encrypt files intended to be accessed by others as well as
decrypt files meant for us.

### Encrypting a file

Suppose we have a file named __myfile.txt__ that contains a message we want to
encrypt. The idea is that we would also indicate who can decrypt the message.
With standard GPG, we would indicate this by using `--recipient <some id>`
where the id could be an email address like __bob@example.com__ or a specific
key's id. [This GPG page](https://www.gnupg.org/documentation/manuals/gnupg/Specify-a-User-ID.html) has a list of all possible forms of ID that can be used, although I typically stick to an email address. As a note, you can provide more than one recipient, which can be handy in a variety of situations including when you want to include yourself as a recipient so you can decrypt the message to read it later yourself.

```
gpg --encrypt --recipient bob@example.com --output myfile.txt.gpg myfile.txt
```

The above would encrypt the file named __myfile.txt__ to be decrypted by
__bob@example.com__ and store the output as __myfile.txt.gpg__.

This requires us to have Bob's public key with an id of __bob@example.com__
associated, otherwise when encrypting we have no idea what public key to use.

### Decrypting a file

Decrypting is fairly straightforward. We specify that we want to decrypt a file
and optionally the output file we want to store the results. GPG is fairly
smart and will find the appropriate private key to use when decrypting based on
the recipients.

```
gpg --decrypt --output myfile.txt myfile.txt.gpg
```

The above example would look for a private key with an associated user id of
__bob@example.com__ to use when decrypting. If GPG cannot find a private key
that fits one of the recipients, it'll indicate a failure. Otherwise, you'll
see a result like below:

```
$ gpg --decrypt --output hello.txt hello.txt.gpg
gpg: encrypted with 4096-bit RSA key, ID 0x588B4B090695884C, created 2019-03-01
      "Chip Senkbeil (Personal [Senkbeil]) <chip@senkbeil.org>"
```

## Using my GPG key for encrypting passwords

Great, so we can encrypt and decrypt files using GPG! Now it's time to install
[pass](https://passwordstore.org/) so we can manage our passwords and keep them
secure using GPG. The __pass__ utility is often available as a package on
platforms like Fedora, ArchLinux, and even Mac OS X:

- Fedora: `dnf install pass`
- ArchLinux: `pacman -S pass`
- Mac OS X: `brew install pass`

__Pass__ itself is a fairly straightforward bash script that manages passwords
by storing each password in an individual files and encrypting them using GPG.
The idea is that __pass__ encrypts files specifying ourselves as recipient so
we can decrypt and access passwords later.

### Initializing the password store

With __pass__ installed, we need to initialize it by indicating what key (or
multiple keys) we want to use when decrypting password files. To do this, we
run `pass init <some id>`, where the ID could be a specific encryption key like
my subkey of __0x588B4B090695884C__, an email address like my user id of
__chip@senkbeil.org__, or some other form of key identification. For me, I just
used `pass init chip@senkbeil.org`.

This should create a new directory at __$HOME/.password-store__ and store the
id of the key used in __$HOME/.password-store/.gpg-id__.

Finally, __pass__ provides a method to historically save changes to passwords
using git. To begin using that functionality, we also need to initialize our
git repository via `pass git init`. All future git operations such as pushing
updates to a remote backup are done via `pass git push` and other
interactions on top of `pass git`.

### [Optional] Importing passwords from lastpass

> If you don't use __LastPass__ to manage your passwords, you can skip this
> step; however, if you use some other form of password management, chances are
> that you want to migrate your existing passwords over to __pass__ rather than
> starting from scratch. I'd recommend checking out the multi-platform [pass import](https://github.com/roddhjav/pass-import) extension and reading more
> about how to export your passwords from an existing platform.

After initializing pass, I needed to import my passwords from [lastpass](https://www.lastpass.com/), which is what I used for work and personal use before making the switch. Luckily for me, there were a variety of scripts and extensions I could use to import my passwords into pass _after_ I had exported them from _lastpass_.

To export my passwords to a CSV, I navigated the lastpass web interface and
selected __More Options > Advanced > Export__.

From there, I could either install the multi-platform [pass import](https://github.com/roddhjav/pass-import) extension and import my passwords via `pass import lastpass.csv` or use the ruby script [lastpass2pass.rb](https://git.zx2c4.com/password-store/tree/contrib/importers/lastpass2pass.rb). To be honest, I've forgotten which I used as it's been over half a year since I made the switch. Regardless, the result was that I now had all of my passwords and other associated information (like usernames) imported with each file having a name like __example.com__ to represent a website whose credentials I had stored. This made it easier to integrate with 3rd-party utilities like [browserpass](https://github.com/browserpass/browserpass-extension).

### Using password store

With __Pass__ initialized and (optionally) existing passwords imported, we're
good to go to begin using it.

> __Pass__ has an excellent manual page via `man pass` as well as a handy help
> section via `pass --help` to get an indepth understanding of the tool's
> functionality.

By default, executing `pass` will provide a list of passwords based on a
directory structure. In the example below, we have two folders - Personal and
Work - that have some passwords stored for different websites (although we
aren't limited purely to websites here). If you looked within the password
store directory, you'd find files like
__$HOME/.password-store/Personal/example.com.gpg__.

```
Password Store
├── Personal
│   ├── example.com
│   ├── another.example.com
├── Work
│   ├── mywork.example.com
```

My main uses of __pass__ are the following:

1. Get the contents of passwords from the first lines of GPG files via `pass
   show -c Personal/example.com`, which adds the password to your clipboard for
   45 seconds
2. Generate new passwords via `pass generate Personal/some-new-name
   32`, where I specify a request for a 32-character long password
3. Edit existing passwords via `pass edit Personal/example.com`, which opens my
   default editor of vim set via __$EDITOR__

__Pass__ has a variety of other functions and extensions you can add, but my
main three are part of the CRUD-style operations of creating, editing, and
reading passwords. Changes to passwords will also be reflected in our git
repository that we initialized earlier.

## Using my GPG key for email encryption

> This is a more personal section about how I use GPG in combination with my
> offline mail managed by [neomutt](https://neomutt.org/) and indexed with
> [notmuch](https://notmuchmail.org/). Your setup may be entirely different,
> so you should definitely do your own research here!

Encrypting mail using GPG has never been an incredibly popular option. It's
difficult to get right and the vast majority of people you email on a regular
basis do not even have GPG keys let alone encrypt their mail with them.

I still wanted to give encrypting (and signing discussed later) a try, so
here's the setup I currently have with __neomutt__ that automatically encrypts
mail where possible and still enables __notmuch__ to index encrypted mail so we
can easily search through it.

### Neomutt configuration

Below I have __crypt.mutt__, a stripped-down version of my GPG-related
configurations for neomutt where I only have listed ones related to encryption
(not signing which we will discuss later):

```bash
# << CRYPTO: GENERAL CONFIG >>

# Use GPGME backend instead of classic code
set crypt_use_gpgme = "yes"

# Automatically encrypt replies to encrypted emails
# NOTE: Set by default
set crypt_replyencrypt = "yes"

# Auto encrypt out outgoing messages
# NOTE: Will ALWAYS try to encrypt even if no keys are available
#       so this is turned off since most people we email won't
#       have a public key at all!
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
set pgp_default_key = "0x588B4B090695884C"
```

### Notmuch configuration

When using __notmuch__ to index mail, the tool relies on being able to access
the contents of the mail. If mail is encrypted as we configured above,
__notmuch__ is not going to be able to index the mail.

Luckily, we can configure __notmuch__ to use GPG keys to decrypt mail when
indexing. This relies on a database-specific setting called __index.decrypt__.
If set to _nostash_ or _true_, __notmuch__ will use GPG keys to decrypt mail
when encountered. The default is _auto_, which will only use stashed session
keys and not those available on our computer (or YubiKey).

Quoting from [notmuch config manpage](https://notmuchmail.org/manpages/notmuch-config-1/):

> When  indexing  an encrypted e-mail message, if this variable is set to true,
> notmuch will try to decrypt the message  and  index the  cleartext,  stashing a
> copy of any discovered session keys for the message.  If auto, it will try to
> index the cleartext if a  stashed  session  key  is already known for the
> message (e.g.  from a previous copy), but will not try to  access  your  secret
> keys.  Use false to avoid decrypting even when a stashed session key is already
> present.

> nostash is the same as  true  except  that  it  will  not  stash
> newly-discovered session keys in the database.

For me, I set to _nostash_ as I have my keys stored on YubiKeys with password
protection:

```
notmuch config index.decrypt set nostash
```

Now, when __notmuch__ is indexing mail, it can take advantage of my GPG key(s)
to handle any encrypted mail it encounters.

## What's next?

In [the next post](/posts/applying-gpg-and-yubikey-part-4-signing), I'll be
explaining how to configure git to sign commits and update neomutt to use a
signing key for our email that can work independently or in combination with
encryption.
