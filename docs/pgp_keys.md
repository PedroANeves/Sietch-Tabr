# Generate PGP Keys
Usually done only once.

Repository needs a GPG signing key, common setup is:

## Generate a (`C`ertfy) Master Key
A Master Key should only be able to certify new keys, never used to sign packages.
Create a `./master-key.batch` for ease of use:
```text
Key-Type: RSA
Key-Length: 4096
Key-Usage: cert
Name-Real: Alice
Name-Email: alice@example.com
Expire-Date: 0
%ask-passphrase
%commit
```

Run `gpg --full-generate-key --batch master-key.batch` and type a passphrase.
>! Any weird errors like "gpg: signing failed: Inappropriate ioctl for device"
    might be solved with `export GPG_TTY=$(tty)` before generation.

Check key creation with `gpg -k alice`:
```text
gpg: checking the trustdb
gpg: marginals needed: 3  completes needed: 1  trust model: pgp
gpg: depth: 0  valid:   1  signed:   0  trust: 0-, 0q, 0n, 0m, 0f, 1u
/home/alice/.gnupg/pubring.kbx
-----------------------------
pub   rsa4096 2026-04-06 [C]
      CD82F1CC232BA5722F9C5E12AEA73426672103D7
uid           [ultimate] Alice <alice@example.com>
```

## Add a (`S`igning) Sub Key
Run `gpg --edit-key CD82F1CC232BA5722F9C5E12AEA73426672103D7`
```text
gpg (GnuPG) 2.4.7; Copyright (C) 2024 g10 Code GmbH
This is free software: you are free to change and redistribute it.
There is NO WARRANTY, to the extent permitted by law.

Secret key is available.

sec  rsa4096/AEA73426672103D7
     created: 2026-04-06  expires: never       usage: C   
     trust: ultimate      validity: ultimate
[ultimate] (1). Alice <alice@example.com>

gpg> 

```

- Type `addkey`,
- select **(4) RSA (sign only)**,
- set keysize to `4096`,
- valid for `2y`,
- confirm twice with `y`, `y`,
- and `save`.

Running `gpg --list-keys` shows both:
```text
/home/alice/.gnupg/pubring.kbx
-----------------------------
pub   rsa4096 2026-04-06 [C]
      CD82F1CC232BA5722F9C5E12AEA73426672103D7
uid           [ultimate] Alice <alice@example.com>
sub   rsa4096 2026-04-06 [S] [expires: 2028-04-05]

```

## Exporting Keys
- Public key: `gpg --export --armor Alice > alice.pub.asc`,
    this key will be available at the repo on `/keys/alice.pub.asc`.

- Master key: `gpg --export-private-keys --armor Alice > alice.sec.asc`,
    this key should **NEVER** leak online,
    hopefully stays offline via [paperkey](https://github.com/dmshaw/paperkey).

- Sub Key: `gpg --export-private-subkeys --armor Alice > alice.sub.asc`,
    this key should never leak neither,
    but a passphrase-less version it will be uploaded to GitHub secrets
    on `GPG_SUB_KEY` in a base64 format.

## Removing Passphrase From Sub Key
Import the sub key on a temporary gpg keyring, remove the passphrase and export.
```bash
export GNUPGHOME=$(mktemp -d)
gpg --import alice.sub.key
gpg --edit-key Alice
```
Type `passwd`, type your old passphrase,
leave both new passphrase for no passphrase,
select `<Yes, No passphrase is needed.>` and `save`.

Now export the passphrase-less sub key in base64 for GitHub Secrets:
`gpg --export-private-subkey --armor Alice | base64 -w 0 > gh_secret_key.txt`
(On GitHub CI we will `echo { secrets.PGP_KEY } | base64 -d | gpg --import`)

Get the Sub Key ID with `gpg --list-secret-keys --keyid-format LONG Alice`,
Key ID is the 16 characters after `ssb   rsa4096/`.

Finally, restore your old gpg home.
```bash
rm -rf "${GNUPGHOME}"
unset GNUPGHOME
```

## Final Values

- Key ID: 16 characters.
- `alice.sec.asc`: Master Key, keep safe!
- `alice.pub.asc`: Public Key, goes on `/keys/` in the repo.
- `alice.sub.asc`: Sub Key with passphrase, may be kept as backup or deleted.
- `gh_secret_key.txt`: base64 Sub Key passphrase-less, uploaded to GitHub Secrets.

Eventually, you will need to [update the key expiration date](./extend_subkey_expiration.md).

