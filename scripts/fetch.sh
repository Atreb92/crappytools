#!/usr/bin/env bash
# Download the release .debs of every repo in tools.txt into debs/ (newest $KEEP releases each, no +debug builds).
# Only debs listed in pinned.sha256 are kept. Needs the gh CLI (GH_TOKEN set in CI).
set -euo pipefail
cd "$(dirname "$0")/.."
KEEP=${KEEP:-3}

rm -rf debs; mkdir debs
grep -v -e '^#' -e '^$' tools.txt | while read -r repo; do
  for tag in $(gh release list -R "$repo" --limit "$KEEP" --json tagName -q '.[].tagName'); do
    gh release download "$tag" -R "$repo" -p '*.deb' -D debs --clobber || echo "no .deb in $repo $tag" >&2
  done
done
rm -f debs/*+debug*.deb
# asset names come from other repos: accept only plain deb file names
for f in debs/*; do [[ $(basename "$f") =~ ^[A-Za-z0-9._+-]+\.deb$ ]] || { echo "rejecting odd asset name: $f" >&2; rm -f "$f"; }; done
# only serve debs whose hash you pinned (scripts/pin.sh); anything else, e.g. a swapped asset, is skipped
for f in debs/*.deb; do
  h=$(sha256sum "$f" | cut -d' ' -f1)
  grep -qx "$h  $(basename "$f")" pinned.sha256 || { echo "::warning::not pinned, skipped: $(basename "$f") ($h)" >&2; rm -f "$f"; }
done
ls debs
