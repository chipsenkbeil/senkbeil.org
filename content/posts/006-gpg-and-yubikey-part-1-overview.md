+++
title = "Applying GPG and Yubikey: Part 1 (Overview)"
slug = "applying-gpg-and-yubikey-part-1-overview"
date = "2019-08-12"
categories = [ "applying" ]
tags = [ "gpg", "yubikey" ]
+++

Today is going to be the first in a series of posts I want to write about
applying GPG and YubiKey. I won't pretend that I am an expert on either GPG or
Yubikey. Instead, I'll be focusing on how I have been using GPG and a variety
of Yubikey devices to enhance my computer experience.

In this post, I'm going to dive into GPG and YubiKey at a high level and
explain what they are to my understanding and how I am using them.

## What is GPG?

To quote [GnuPG's website](https://gnupg.org/):

> GnuPG is a complete and free implementation of the OpenPGP standard as defined by RFC4880 (also known as PGP). GnuPG allows you to __encrypt and sign your data and communications__; it features a versatile key management system, along with access modules for all kinds of public key directories.

To my understanding, GPG uses a method of encryption known as [public key
asymmetric cryptography](https://en.wikipedia.org/wiki/Public-key_cryptography), using key pairs to encrypt and decrypt
information. GPG has a bunch of other algorithms related to ciphers,
hashing, and compression, but my main use case is with public key
cryptography typically revolving around [RSA](https://en.wikipedia.org/wiki/RSA_(cryptosystem)) usage. Additionally, GPG can add digital signatures to messages, which is another use case that I have leveraged.

GPG offers three different capabilities with RSA:

- Encryption
- Digital Signatures
- Authentication

GPG also has certification capabilities to enable you to certify other
keys, but the primary capabilities that I use day-to-day are the former
three.

In a nutshell, I've been using GPG to these things:

- Encrypt/decrypt my passwords managed by
    [pass](https://passwordstore.org/)
- Digitally sign my email & git commits
- Authenticate into my personal servers

While another big use of GPG is to encrypt your email, I've rarely encrypted
(or decrypted) any email myself. I do have neomutt configured to encrypt
email _if_ I have all of the recipients' public keys, but I don't know anyone
using encrypted mail aside from [Luke Smith](https://lukesmith.xyz/).

## What is YubiKey?

![Picture of YubiKeys](/img/post/my-yubikeys.png)

To my knowledge, a [YubiKey](https://en.wikipedia.org/wiki/YubiKey) is a
hardware device built for authentication. Made by [Yubico](http://yubico.com/),
these keys provide a variety of features ranging from [one-time password
(OTP)](https://en.wikipedia.org/wiki/One-time_password) generation to [U2F
(universal two-factor)](https://en.wikipedia.org/wiki/Universal_2nd_Factor)
authentication.

I use a YubiKey in two ways:

- one-time passwords (OTP)
- public-key cryptography (encryption/authentication/signing)

At work, we have YubiKeys configured with one-time passwords to sign in to
various services by touching the device. It's incredibly handy versus needing
to open my phone for Duo Mobile two-factor authentication.

Separately, I use YubiKeys (both at work and home) to store and use my GPG
keys. Yubico - the company producing YubiKey devices - released the 4th
generation of YubiKey back in 2015 that supported OpenPGP with up to
4096-bit RSA keys.

Normally, when you want to access your GPG keys, they're located somewhere on
your local computer. If you're using a single device, this isn't the biggest
deal, but is still prone to security concerns if someone is able to remotely
access your computer and acquire your private keys.

With YubiKey, I'm able to safely move my GPG keys over to the external
device, where they __cannot__ be exported off of the device later. Instead,
decryption and signing requests will be done on the YubiKey device itself. This
means even if your computer is compromised from a remote attacker, your keys
will remain safe, although your keys can still be used by GPG until the cache of
your YubiKey password has expired.

Another bonus is that I don't need to worry about copying my keys across
different computers. Instead, I can transfer the YubiKey between devices.

## What did I do?

There was a lot of learning on my part to figure out how to set up GPG keys,
how to move said keys to YubiKeys, and what configuration changes and tools
were needed to get the environment I wanted/needed.

This wasn't my first time creating a GPG key. When [publishing releases
for Apache Toree](https://checker.apache.org/keys/4282790f8e3b4bba.html) and
[publishing releases for Ensime's Scala Debugger](https://search.maven.org/search?q=g:org.scala-debugger) as early as June of 2015, I created a new key to do the signing, not really understanding what the key was but knowing that I needed one to upload jars.

Enter 2019 and I had become interested in switching from [LastPass](https://lastpass.com/) to [Pass](https://passwordstore.org/) in order to remove the need for network access when accessing my passwords. Yes, LastPass was able to cache passwords and even had its own CLI that I could embed into my various configuration scripts, but I often had issues where the cache was invalidated or some reason prevented me from accessing my passwords when I needed them. Additionally, I wanted more direct control over my password data.

## What's next?

In the next post, I'll be explaining how I set up my GPG key and configured it
for encrypting my passwords.
