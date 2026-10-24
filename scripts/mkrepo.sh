#!/usr/bin/env bash
# Build the flat APT repo in site/ from the debs in debs/ plus everything in static/.
# static/icons/<package>.png and static/depictions/<package>.json, when present, replace the
# Icon and SileoDepiction fields in the index, so the debs themselves need no rebuild.
# Needs only ar, tar, xz, bzip2, sha256sum, md5sum.
set -euo pipefail
cd "$(dirname "$0")/.."
BASE=${BASE:-https://atreb92.github.io/crappytools}

rm -rf site; mkdir -p site/debs
cp -r static/. site/
cp debs/*.deb site/debs/

: > site/Packages
for deb in site/debs/*.deb; do
  m=$(ar t "$deb" | grep ^control.tar); ctl=$(ar p "$deb" "$m" | tar -x$([ "${m##*.}" = xz ] && echo J || echo z)O ./control)
  id=$(sed -n 's/^Package: //p' <<<"$ctl")
  if [ -f "static/icons/$id.png" ]; then ctl=$(grep -v '^Icon:' <<<"$ctl"; echo "Icon: $BASE/icons/$id.png"); fi
  if [ -f "static/depictions/$id.json" ]; then ctl=$(grep -v '^SileoDepiction:' <<<"$ctl"; echo "SileoDepiction: $BASE/depictions/$id.json"); fi
  printf '%s\nFilename: debs/%s\nSize: %s\nMD5sum: %s\nSHA256: %s\n\n' \
    "${ctl%$'\n'}" "$(basename "$deb")" "$(stat -c %s "$deb")" \
    "$(md5sum < "$deb" | cut -d' ' -f1)" "$(sha256sum < "$deb" | cut -d' ' -f1)" >> site/Packages
done
xz -kf9 site/Packages
bzip2 -kf site/Packages

cat > site/Release <<REL
Origin: crappytools
Label: crappytools
Suite: stable
Version: 1.0
Codename: ios
Architectures: iphoneos-arm64
Components: main
Description: crappy jailbreak tools, one source
REL
touch site/.nojekyll
echo "site/ built: $(grep -c '^Package:' site/Packages) package version(s)"
