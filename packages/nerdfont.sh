#!/usr/bin/env bash

. scripts/utils.sh

repo="ryanoasis/nerd-fonts"
description="Icon font aggregator."

latest() {
  _version_from_gh_api "${repo}"
}

download() {
  [[ $# == 2 ]] \
    || die "Usage: download '1.2.3' 'path/to/sources/<package>/'"
  local version=$1
  local directory=$2

  local filename="0xProto.tar.xz"
  local name="nerdfont"

  echo "Downloading ${name} v${version} from GitHub ..."
  wget -O "${directory}/${filename}" \
    "https://github.com/${repo}/releases/download/v${version}/${filename}"
}

build() {
  [[ $# == 3 ]] \
    || die "Usage: build 'name' 'path/to/sources/<package>' 'path/to/releases/<package>'"
  local name=$1
  local source_dir=$2
  local release_dir=$3

  local zipped_package="${source_dir}/0xProto.tar.xz"
  local font_dir="${release_dir}/usr/share/fonts/truetype/0xproto"

  rm -r "${release_dir}/usr/bin/"
  mkdir -p "${font_dir}"
  tar -xf "${zipped_package}" -C "${font_dir}/" --wildcards '0xProtoNerdFont*.ttf'
}
