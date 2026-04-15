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
