#!/usr/bin/env bash

. scripts/utils.sh

repo="neovim/neovim"
description="Hyperextensible Vim-based text editor."

latest() {
  _version_from_gh_api "${repo}"
}

download() {
  [[ $# == 2 ]] \
    || die "Usage: download '1.2.3' 'path/to/sources/<package>/'"
  local version=$1
  local directory=$2

  local name="${repo#*/}"
  local filename="nvim-linux-x86_64.tar.gz"

  echo "Downloading ${name} v${version} from GitHub ..."
  wget -O "${directory}/${name}.tar.gz" \
    "https://github.com/${repo}/releases/download/v${version}/${filename}"
}

build() {
  [[ $# == 3 ]] \
    || die "Usage: build 'name' 'path/to/sources/<package>' 'path/to/releases/<package>'"
  local name=$1
  local source_dir=$2
  local release_dir=$3

  local zipped_package="${source_dir}/${name}.tar.gz"
  tar -xzf "${zipped_package}" -C "${release_dir}/" "nvim-linux-x86_64/"
  rm -r "${release_dir}/usr"
  mv -T "${release_dir}/"{nvim-linux-x86_64,usr}
  ln -sr "${release_dir}/usr/bin/"{nvim,neovim}
}
