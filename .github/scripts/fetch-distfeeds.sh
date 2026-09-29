#!/usr/bin/env bash
set -euo pipefail

destination=${1:?usage: fetch-distfeeds.sh DESTINATION}
base_url=https://w1700k.github.io/builds
temp_dir=$(mktemp -d)
trap 'rm -rf "$temp_dir"' EXIT

curl --fail --show-error --silent --location --retry 3 --retry-all-errors \
  --output "$temp_dir/distfeeds.list" "$base_url/distfeeds.list"
curl --fail --show-error --silent --location --retry 3 --retry-all-errors \
  --output "$temp_dir/vermagic.txt" "$base_url/vermagic.txt"

vermagic=$(tr -d '\r\n' < "$temp_dir/vermagic.txt")
if [[ ! $vermagic =~ ^[[:xdigit:]]{32}$ ]]; then
  echo '::error::Invalid or empty vermagic.txt' >&2
  exit 1
fi

if grep -Ev '^(#.*|[[:space:]]*|https://downloads\.openwrt\.org/snapshots/.*/packages\.adb)$' \
    "$temp_dir/distfeeds.list"; then
  echo '::error::Unexpected entry in distfeeds.list' >&2
  exit 1
fi

if ! grep -Eq "^https://downloads\\.openwrt\\.org/snapshots/targets/airoha/an7581/kmods/[^/]+-${vermagic}/packages\\.adb$" \
    "$temp_dir/distfeeds.list"; then
  echo '::error::distfeeds.list and vermagic.txt refer to different kmod builds' >&2
  exit 1
fi

mkdir -p "$destination/etc/apk/repositories.d" "$destination/etc"
install -m 644 "$temp_dir/distfeeds.list" "$destination/etc/apk/repositories.d/distfeeds.list"
install -m 644 "$temp_dir/vermagic.txt" "$destination/etc/vermagic.txt"
sha256sum "$destination/etc/apk/repositories.d/distfeeds.list" "$destination/etc/vermagic.txt"
