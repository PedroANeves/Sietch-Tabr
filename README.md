# Sietch Tabr
Personal APT Repository using `reprepro` deployed as static pages.

[Currently deployed packages and their versions.](./packages/versions.ini)

# Development
## Requirements
Designed for Debian 13 (trixie)

Build a `dev.Containerfile` image (`make dev`) or manually install requirements:
- gnupg
- reprepro
- ca-certificates
- git
- wget

### [Generate PGP Keys](./docs/pgp_keys.md)
Get `alice.pub.asc`, the subkey ID, and `gh_secret_key.txt` from generated keys.

Either run gpg manually with `GNUPGHOME=./.gnupg/ gpg ...` or
use the dev container with `make dev gpg ...`.

### Update The Signing Key Id fingerprint
```bash
cat path/to/alice.pub.asc | gpg --import --dearmor
sed "s/SignWith: .*\!/SignWith: $(gpg -k Alice | grep -Po "      \K[0-9A-F]{40}")\!/" conf/distributions
```

### Add Sub Key to local gpg directory
`cat path/to/gh_secret_key.txt | base64 -d | make dev gpg --import`

### Run test
`make test`
