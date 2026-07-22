#!/bin/sh

set -eu

usage() {
  echo "Usage: $0 <formula> <tag>" >&2
  echo "Example: $0 nslite v1.0.2" >&2
  exit 2
}

[ "$#" -eq 2 ] || usage

formula_name=$1
tag=$2

if ! printf '%s\n' "$formula_name" | grep -Eq '^[0-9A-Za-z][0-9A-Za-z@+._-]*$'; then
  echo "Invalid formula name: $formula_name" >&2
  usage
fi

if ! printf '%s\n' "$tag" | grep -Eq '^[0-9A-Za-z][0-9A-Za-z._+-]*$'; then
  echo "Invalid tag: $tag" >&2
  usage
fi

script_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
tap_dir=$(dirname -- "$script_dir")
formula="$tap_dir/Formula/$formula_name.rb"

[ -f "$formula" ] || {
  echo "Formula not found: $formula" >&2
  exit 1
}

current_url=$(awk '
  /^  url "/ {
    value = $0
    sub(/^  url "/, "", value)
    sub(/"$/, "", value)
    print value
    exit
  }
' "$formula")

case "$current_url" in
  https://github.com/*/archive/refs/tags/*.tar.gz)
    repository_url=${current_url%/archive/refs/tags/*}
    ;;
  *)
    echo "Unsupported formula URL: $current_url" >&2
    echo "Expected a GitHub tag archive URL" >&2
    exit 1
    ;;
esac

archive_url="$repository_url/archive/refs/tags/$tag.tar.gz"
work_dir=$(mktemp -d "${TMPDIR:-/tmp}/formula-update.XXXXXX")
trap 'rm -rf "$work_dir"' EXIT HUP INT TERM
archive="$work_dir/$tag.tar.gz"
updated_formula="$work_dir/$formula_name.rb"

echo "Downloading $archive_url"
curl --fail --location --silent --show-error --output "$archive" "$archive_url"

if command -v sha256sum >/dev/null 2>&1; then
  checksum=$(sha256sum "$archive" | awk '{print $1}')
elif command -v shasum >/dev/null 2>&1; then
  checksum=$(shasum -a 256 "$archive" | awk '{print $1}')
else
  echo "Neither sha256sum nor shasum is available" >&2
  exit 1
fi

awk -v current_url="$current_url" -v archive_url="$archive_url" -v checksum="$checksum" '
  $0 == "  url \"" current_url "\"" {
    print "  url \"" archive_url "\""
    url_count++
    replace_checksum = 1
    next
  }
  replace_checksum && index($0, "  sha256 \"") == 1 {
    print "  sha256 \"" checksum "\""
    checksum_count++
    replace_checksum = 0
    next
  }
  { print }
  END {
    if (url_count != 1 || checksum_count != 1) {
      exit 1
    }
  }
' "$formula" > "$updated_formula" || {
  echo "Could not identify exactly one url and associated sha256 field in $formula" >&2
  exit 1
}

mv "$updated_formula" "$formula"

echo "Updated Formula/$formula_name.rb"
echo "  tag:     $tag"
echo "  sha256:  $checksum"
