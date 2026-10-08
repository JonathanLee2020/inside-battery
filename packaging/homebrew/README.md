# Inside Battery Homebrew tap

After the tap and v0.2.0 release have been published:

```sh
brew install --cask JonathanLee2020/inside-battery/inside-battery
```

This is an Apple Silicon development preview, not an official `homebrew/cask`
listing. It is ad-hoc signed and not notarized. macOS Gatekeeper can prevent it
from opening. The cask preserves quarantine and does not silently enable a root
helper. Fresh-install power switching and restart persistence remain unverified.

The cask's SHA-256 matches the versioned GitHub release ZIP. Install the complete
app into Applications before requesting helper approval; avoid multiple app copies.

No source license has been selected yet. The tap recipe does not grant a license
to reuse the application's source code.
