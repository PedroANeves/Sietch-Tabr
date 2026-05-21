#!/usr/bin/env bash

. scripts/utils.sh

repo="junegunn/fzf"
description="A command-line fuzzy finder."

latest() {
  _version_from_gh_api "${repo}"
}

download() {
  [[ $# == 2 ]] \
    || die "Usage: download '1.2.3' 'path/to/sources/<package>/'"
  local version=$1
  local directory=$2

  local filename="%name%-${version}-linux_amd64.tar.gz"

  _download_file_from_gh "${repo}" "${filename}" "${version}" "${directory}"
}

build() {
  [[ $# == 3 ]] \
    || die "Usage: build 'name' 'path/to/sources/<package>' 'path/to/releases/<package>'"
  local name=$1
  local source_dir=$2
  local release_dir=$3

  _unzip_elf_from_simple_tar_gz "${name}" "${source_dir}" "${release_dir}"
}
