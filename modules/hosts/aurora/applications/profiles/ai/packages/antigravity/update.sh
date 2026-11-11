#!/usr/bin/env bash
# Asks GitHub for the latest antigravity-cli release tag, downloads the
# linux asset to compute its hash, and rewrites default.nix in place.
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")"

version=$(gh release view --repo google-antigravity/antigravity-cli --json tagName -q .tagName)
url="https://github.com/google-antigravity/antigravity-cli/releases/download/${version}/agy_cli_linux_x64.tar.gz"

echo "latest antigravity-cli: $version"
base32=$(nix-prefetch-url "$url" 2>/dev/null | tail -1)
if [[ -z "$base32" ]]; then
  echo "error: failed to prefetch $url" >&2
  exit 1
fi
hash=$(nix hash convert --hash-algo sha256 --to sri "$base32")

sed -i \
  -e "s|version = \".*\"; # nix-update: version|version = \"${version}\"; # nix-update: version|" \
  -e "s|hash = \".*\"; # nix-update: hash|hash = \"${hash}\"; # nix-update: hash|" \
  default.nix

grep -q "version = \"${version}\"; # nix-update: version" default.nix
grep -q "hash = \"${hash}\"; # nix-update: hash" default.nix

echo "updated antigravity-cli (default.nix) -> ${version}"

