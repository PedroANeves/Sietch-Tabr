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
