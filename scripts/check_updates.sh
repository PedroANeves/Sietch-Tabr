#!/usr/bin/env bash
set -e

# check_updates.sh - update `packages/versions.ini` with latest version
# using `latest` function for each `packages/*.sh`

die() { echo "$*" 1>&2 ; exit 1; }

VERSIONS="packages/versions.ini"
for f in packages/*.sh; do
  latest() {
    die "${f} has no 'latest' defined! (latest 'user/project' == '1.2.3')"
  }

  pkg=$(basename $f .sh)
  echo "Processing ${pkg} (${f})"

  . "${f}"
  current_version=$(sed -n "s/^${pkg}=//p" "${VERSIONS}")
  latest_version=$(latest)

  if [[ -z $current_version ]]; then
    # new package
    echo "${pkg} is new (${latest_version})"
    echo "${pkg}=${latest_version}" >> "${VERSIONS}"
    sort "${VERSIONS}" -o "${VERSIONS}"
  elif [[ $current_version != $latest_version ]]; then
    # update package
    echo "${pkg} updated (${current_version}) -> (${latest_version})"
    sed -i "s/^${pkg}=${current_version}$/${pkg}=${latest_version}/" "${VERSIONS}"
  else
    # up to date
    echo "${pkg} is up to date (${current_version})"
  fi
done
