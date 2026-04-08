#!/usr/bin/env bash
set -e

# Sietch Tabr development container

die() { echo "$*" 1>&2 ; exit 1; }

REPO_URL=$1
GPG_KEY=$2
CODENAME=$3
PACKAGES="${4}"

wget -qO - "${REPO_URL}/keys/${GPG_KEY}" | gpg --dearmor > /usr/share/keyrings/sietch-tabr.gpg

echo "deb [ arch=amd64 signed-by=/usr/share/keyrings/sietch-tabr.gpg] ${REPO_URL} ${CODENAME} main" > \
/etc/apt/sources.list.d/sietch-tabr.list

apt-get update \
-o Dir::Etc::sourcelist="sources.list.d/sietch-tabr.list" \
-o Dir::Etc::sourceparts="-" \
-o APT::Get::List-Cleanup="0"

DEBIAN_FRONTEND=noninteractive apt-get install -y \
  "${PACKAGES}"

for p in "${PACKAGES}"; do
  if command -v "${p}" >/dev/null 2>&1 ; then
    echo "${p} installed. [$("${p}" --version)]"
  else
    echo "${p} is missing!"
  fi
done && echo "OK!"
