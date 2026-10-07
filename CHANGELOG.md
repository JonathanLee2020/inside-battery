# Changelog

Versions identify source snapshots, not downloadable app releases.

## 0.1.0 — 2026-10-08

- Native macOS menu-bar battery percentage, notification-driven updates, and
  charging, Low Power, and High Power indicators.
- Native-style Battery menu with energy-mode controls and a visible Quit action.
- Optional signed XPC helper for power-mode changes, with saved-mode verification
  and a repair action for mismatched development builds.
- Experimental significant-energy app list, guarded to macOS 26.2; status and
  empty results occupy one row.
- One app build workflow. Review variants have been retired.

Verification: executable self-checks and bundle/helper signature checks are run
for the snapshot. XCTest is unavailable in the current Command Line Tools
installation. Desktop helper approval and mode switching after registration
changes remain unverified; this is a development snapshot, not a stable release.
