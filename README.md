# crappytools

Crappy jailbreak tools, one Sileo source. Rootless, iOS 15+.

In Sileo: Sources › **+** and add `https://atreb92.github.io/crappytools/`.

| Package | What it does |
|---|---|
| [crappytouch](https://github.com/Atreb92/crappytouch) | lets a computer running scrcrappy drive the phone over USB |
| [crappyproxy](https://github.com/Atreb92/crappyproxy) | Control Centre toggle for the Wi-Fi proxy |

## How it works

No server. A GitHub Action (hourly, on push, or by hand under Actions) does this:

1. `scripts/fetch.sh` downloads the release `.deb` files of every repo in `tools.txt` (newest 3 releases each, no `+debug` builds)
   and keeps only those whose SHA256 is listed in `pinned.sha256`. Anything else is skipped with a warning.
2. `scripts/mkrepo.sh` builds the APT index (`Packages`, `Release`) in `site/`, together with `static/`.
3. GitHub Pages serves `site/`.

To publish an update:

1. Release it in the tool's own repo (`gh release create v<version> <deb>`).
2. Pin the hash of your **local** build, then push: `scripts/pin.sh path/to/<deb> && git add pinned.sha256 && git commit && git push`.

The push deploys right away. Without step 2 the new version is skipped, so a swapped or tampered
release asset never reaches the source on its own.

## Adding a tool

1. Add its `owner/repo` to `tools.txt`. Its releases must carry the `.deb` as an asset.
2. Optional: `static/icons/<package id>.png` and `static/depictions/<package id>.json`. They replace the
   `Icon` and `SileoDepiction` fields in the index, so the deb needs no rebuild.

The repo is unsigned, like most hobby sources: Sileo handles that, command-line `apt` does not.

## Licence

MIT, see `LICENSE`.
