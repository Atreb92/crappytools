#!/usr/bin/env bash
# Pin release debs by hash: scripts/pin.sh path/to/your/local/build.deb [...]
# Hash your own build (not a download), then commit pinned.sha256. fetch.sh skips unpinned debs.
set -euo pipefail
cd "$(dirname "$0")/.."
touch pinned.sha256
for f in "$@"; do printf '%s  %s\n' "$(sha256sum "$f" | cut -d' ' -f1)" "$(basename "$f")" >> pinned.sha256; done
sort -u -o pinned.sha256 pinned.sha256
cat pinned.sha256
