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

_unzip_elf_from_simple_tar_gz() {
  # _unzip_elf_from_simple_tar_gz <package> './build/sources/<package>' './build/releases/<package>'
  #
  # A ELF named <name> on a file.tar.gz root:
  # $ tar --list -f /path/to/file.tar.gz
  # ...
  # <name>
  # ...
  #
  [[ $# == 3 ]] \
    || die "Usage: _unzip_elf_from_simple_tar_gz 'name' 'source_dir' 'release_dir'"
  local name=$1
  local source_dir=$2
  local release_dir=$3

  local zipped_package="${source_dir}/${name}.tar.gz"
  tar -xzf "${zipped_package}" -C "${release_dir}/usr/bin/" "${name}"
}

###############################################################################
# build utils
###############################################################################

_init_deb_layout() {
  # _init_deb_layout '<package>'
  [[ $# == 1 ]] \
    || die "Usage: _init_deb_layout 'name'"
  local name=$1

  local releases_dir="./build/releases/${name}"
  mkdir -p "${releases_dir}/usr/bin"
  mkdir -p "${releases_dir}/DEBIAN"
}

_debcontrol() {
  # _debcontrol '<package>' '1.2.3' 'Short Description.'
  [[ $# == 3 ]] \
    || die "Usage: _debcontrol 'name' 'version' 'description'"
  local name=$1
  local version=$2
  local description=$3

  echo "Package: $name"
  echo "Version: $version"
  echo "Section: default"
  echo "Priority: optional"
  echo "Architecture: amd64"
  echo "Maintainer: Pedro A. Neves <PedroANeves@users.noreply.github.com>"
  echo "Description: $description"
}

_build_deb() {
  # _build_deb './build/releases/<package>' './build/debs'
  [[ $# == 2 ]] \
    || die "Usage: _build_deb 'release_dir' 'debs_dir'"
  local release_dir=$1
  local debs_dir=$2

  mkdir -p "${debs_dir}"
  dpkg-deb --build "${release_dir}" "${debs_dir}"
}
