#!/usr/bin/env bash
# Asks GitHub for the latest codex release tag, downloads the linux
# binary asset to compute its hash, and rewrites default.nix in place.
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")"

tag=$(gh release view --repo openai/codex --json tagName -q .tagName)
version=${tag#rust-v}
url="https://github.com/openai/codex/releases/download/${tag}/codex-package-x86_64-unknown-linux-musl.tar.gz"

echo "latest codex: $tag"
base32=$(nix-prefetch-url "$url" 2>/dev/null | tail -1)
if [[ -z "$base32" ]]; then
  echo "error: failed to prefetch $url" >&2
  exit 1
fi
hash=$(nix hash convert --hash-algo sha256 --to sri "$base32")

sed -i \
  -e "s|version = \".*\"; # nix-update: version|version = \"${version}\"; # nix-update: version|" \
  -e "s|tag = \".*\"; # nix-update: tag|tag = \"${tag}\"; # nix-update: tag|" \
  -e "s|hash = \".*\"; # nix-update: hash|hash = \"${hash}\"; # nix-update: hash|" \
  default.nix

grep -q "version = \"${version}\"; # nix-update: version" default.nix
grep -q "tag = \"${tag}\"; # nix-update: tag" default.nix
grep -q "hash = \"${hash}\"; # nix-update: hash" default.nix

echo "updated codex (default.nix) -> ${tag}"

