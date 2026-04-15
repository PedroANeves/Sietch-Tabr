#!/usr/bin/env bash
set -e

# download_release.sh - get package files from version on `packages/version.ini`
# using `download` function for each `packages/*.sh`
# skips download if `./build/sources/<package>/` already exists

die() { echo "$*" 1>&2 ; exit 1; }

sed '/^$/d;/^#/d' packages/versions.ini | \
  while IFS='=' read -r name version; do
    f="packages/${name}.sh"
    download() {
      die "${f} has no 'download' defined! (download '1.2.3' ./build/sources/<package>)"
    }

    echo "Downloading '${name}' v${version} ..."

    . "${f}"
    source_dir="./build/sources/${name}"
    if [[ ! -d $source_dir || $1 == "-f" || $1 == "--force" ]]; then
      echo "No ${source_dir} found, Downloading ..."
      mkdir -p "${source_dir}"

      download "${version}" "${source_dir}"
    else
      echo "${name} already downloaded, skipping ..."
    fi
  done

