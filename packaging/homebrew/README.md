# Inside Battery Homebrew tap

Install the latest development preview (0.2.3):

```sh
brew tap JonathanLee2020/inside-battery
brew install --cask JonathanLee2020/inside-battery/inside-battery
```

To upgrade an existing Homebrew install, quit Inside Battery, then run:

```sh
brew update
brew upgrade --cask JonathanLee2020/inside-battery/inside-battery
```

Alternatively, download the ZIP from
[GitHub Releases](https://github.com/JonathanLee2020/inside-battery/releases/tag/v0.2.3),
extract it, and move the complete app to Applications.

This is an Apple Silicon development preview, not an official `homebrew/cask`
listing. It is ad-hoc signed and not notarized. macOS Gatekeeper can prevent it
from opening. The cask preserves quarantine and does not silently enable a root
helper. Fresh-install power switching and restart persistence remain unverified.

The cask's SHA-256 matches the versioned GitHub release ZIP. Install the complete
app into Applications before requesting helper approval; avoid multiple app copies.

No source license has been selected yet. The tap recipe does not grant a license
to reuse the application's source code.

Version 0.2.2 adds Check for Updates in the app menu. Older versions need one
manual or Homebrew upgrade first. In-app updates that change a registered power
helper require manual installation until helper upgrades are verified.
