#!/usr/bin/env bash
set -e

# ./scripts/ Tests

die() { echo "$*" 1>&2 ; exit 1; }

. ./scripts/utils.sh

# mock download
tmp_a=$(mktemp -d pkga_XXXXXX)
echo -e "#!/usr/bin/env bash\n echo 'Im package A'\n" > "$tmp_a/pkga"
chmod +x "$tmp_a/pkga"
mkdir -p ./build/sources/pkga
tar czf ./build/sources/pkga/pkga.tar.gz -C "$tmp_a/" pkga
[[ -f ./build/sources/pkga/pkga.tar.gz ]] || die "mock download failed!"

name="pkga"
version="1.2.3"
release_dir="./build/releases/${name}"
description="Package A."

# build_debs.sh - pre
_init_deb_layout "${name}"
_debcontrol "${name}" "${version}" "${description}" > "${release_dir}/DEBIAN/control"

# <package>.build
_unzip_elf_from_simple_tar_gz "${name}" ./build/sources/pkga "${release_dir}"

# build_debs.sh - post
_build_deb "${release_dir}" "./build/debs"

# Asserts
# _init_deb_layout
[[ -d ./build/releases/pkga/usr/bin/ ]] || die "/usr/bin/ not created!"
[[ -d ./build/releases/pkga/DEBIAN ]] || die "DEBIAN/ not created!"

# _debcontrol
[[ -f ./build/releases/pkga/DEBIAN/control ]] || die "No deb control file!"
[[ -s ./build/releases/pkga/DEBIAN/control ]] || die "control file is empty!"

# _unzip_simple_from_tar_gz
[[ -f ./build/releases/pkga/usr/bin/pkga ]] || die "No pkga in /usr/bin/!"
[[ -x ./build/releases/pkga/usr/bin/pkga ]] || die "pkga is not executable!"

# _build_deb
[[ -f ./build/debs/pkga_1.2.3_amd64.deb ]] || die "No pkga_1.2.3_amd64.deb!"

dpkg --install ./build/debs/pkga_1.2.3_amd64.deb && pkga
