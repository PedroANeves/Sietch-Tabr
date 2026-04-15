# Extending Sub Key Expiration

Every 2 years your key will automatically expire.

## Import the master key
Recover your `alice.sec.asc` and run:
```bash
export GNUPGHOME=$(mktemp -d)
cat alice.sec.asc | gpg import --dearmor
gpg --edit-key Alice
```

## Remove the passphrase
First, remove the passphrase so the exported public and sub key won't need one:
Type `passwd`, type your old passphrase,
leave both new passphrase for no passphrase,
select `<Yes, No passphrase is needed.>` and `save`.

## Update the expiration date
Then, export the sub key:
Select the sub key with `key 1`.
Type `expire` then `2y`.
Then `save`.

## Export the new public and sub keys
```bash
gpg --export --armor Alice > alice.pub.asc
gpg --export-secret-subkeys --armor Alice | base64 -w 0 > gh_secret_key.txt
```

## Update Repository
`alice.pub.asc` goes into `./keys/`.
`gh_secret_key.txt` contents goes into GitHub CI `secrets.PGP_KEY`.

