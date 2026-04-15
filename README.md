# Sietch Tabr
[![Repository CI/CD](https://github.com/PedroANeves/Sietch-Tabr/actions/workflows/ci.yml/badge.svg)](https://github.com/USER/REPO/actions/workflows/ci.yml)
[![Wind Traps (Updater)](https://github.com/PedroANeves/Sietch-Tabr/actions/workflows/update.yml/badge.svg)](https://github.com/USER/REPO/actions/workflows/update.yml)

Personal APT Repository using `reprepro` deployed as static pages.

Every day checks for newer packages.

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

## Adding New Packages
Add a executable `./packages/<package_name>.sh` with the functions:
- `latest`: prints the latest semver for package, e.g. `0.60.0`.
- `download`: downloads a `<package_name>.tar.gz` into `./build/sources/<package_name>/`
- `build`: uses `./build/sources/<package_name>/<package_name>.tar.gz` to
    generate a `./build/debs/<package_name>/<package_name>_<version>_amd64.deb`

There are a couple of helper functions on `./scripts/utils.sh`,
import them with `. scripts/utils.sh` (mainly dealing with GitHub API)
