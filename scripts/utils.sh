#!/usr/bin/env bash

# utils for scripts and packaging

die() { echo "$*" 1>&2 ; exit 1; }

###############################################################################
# packages utils
###############################################################################

_version_from_gh_api(){
  # _version_from_gh_api 'user/project' == '1.2.3'
  #
  # Latest is a GitHub release tagged as 'v<version>'
  #
  [[ $# == 1 ]] \
    || die "Usage: _version_from_gh_api 'user/project'"
  local repo=$1

  local gh_api_url="https://api.github.com/repos/${repo}/releases/latest"
  wget -qO - "${gh_api_url}" | grep -Po '"tag_name": *"v\K[^"]+'
}

_download_tar_gz_from_gh(){
  # _download_tar_gz_from_gh 'user/project' '1.2.3' ./build/sources/<package>
  #
  # Releases from GitHub are files '<name>_<version>_Linux_x86_64.tar.gz' tagged 'v<version>'
  #
  [[ $# == 3 ]] \
    || die "Usage: _download_tar_gz_from_gh 'user/project' '1.2.3' path/to/sources/<package>"
  local repo=$1
  local version=$2
  local directory=$3

  local name="${repo#*/}"
  local filename="${name}_${version}_Linux_x86_64.tar.gz"

  echo "Downloading ${name} v${version} from GitHub ..."
  wget -O "${directory}/${name}.tar.gz" \
    "https://github.com/${repo}/releases/download/v${version}/${filename}"
}
