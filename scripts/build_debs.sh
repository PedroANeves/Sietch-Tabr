#!/usr/bin/env bash
set -e

# build_debs - for each `name=version` in `./packages/versions.ini`
# uses `./build/sources/<name>/<name>/tar.gz`
# with `build` function from `./packages/<name>.sh`
# into `./build/debs/<name>_<version>_amd64.deb`
# skips building if deb already exists

die() { echo "$*" 1>&2 ; exit 1; }

. scripts/utils.sh

sed '/^$/d;/^#/d' packages/versions.ini | \
  while IFS='=' read -r name version; do
    f="packages/${name}.sh"
    build() { die "${f} has no 'build' defined!" ; }

    echo "Building '${name}' v${version} ..."

    . "${f}"

    if [[ ! -f "./build/debs/${name}_${version}_amd64.deb" ]]; then
      echo "No deb for ${name} v${version}, Building ..."

      _init_deb_layout "${name}"
      release_dir="./build/releases/${name}"
      _debcontrol "${name}" "${version}" "${description}" > "${release_dir}/DEBIAN/control"

      build "${name}" "./build/sources/${name}" "${release_dir}"

      _build_deb "${release_dir}" "./build/debs"
    else
      echo "Deb for ${name} found on ./build/debs/, Skipping ..."
    fi
  done

