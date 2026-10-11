# Changelog

Versions preserve source snapshots and, from 0.2.0, prepared downloadable previews.

## Unreleased

## 0.2.3 — 2026-10-11 (development preview)

- Consolidated current UI and energy-data fixes with the Sparkle updater from
  0.2.2; version metadata is now 0.2.3/build 5.
- README now describes the current icons, selected-mode colors, neutral hover,
  charging details, energy-data parsing and signed install/relaunch flow.
- Documents the verified Homebrew fetch/dry run and the downloaded preview's
  Gatekeeper rejection. Developer ID signing and notarization remain pending.

This is a packaging and documentation update; Sparkle behavior is unchanged
from 0.2.2. Verification: 177 executable checks, helper signature pinning, nested
signatures, ZIP round-trip and signed feed/archive checks passed. Local 0.2.3
installed with the original helper/client unchanged; reapplying the current mode
completed without changing saved preferences. Existing public-build helper
upgrade and fresh-install verification limits remain.

## 0.2.2 — 2026-10-08 (development preview)

- Sparkle 2.10.0 integration with Check for Updates, standard update dialog and
  scheduled checks; signed archives/feeds and helper compatibility validation.
- Signed-feed checks and a disposable app's download/install/relaunch passed.
  Privileged-helper upgrades remain unverified and require manual installation.

## 0.2.1 — 2026-10-08 (development preview)

- High Power charge fill is lighter purple with a contrasting grey empty area;
  menu-bar fast-forward marks removed.
- Significant-energy parser filters unnamed system coalitions instead of
  rejecting valid responses or discarding named apps alongside them.
- Selected Energy Mode circles are blue for Automatic, yellow for Low Power,
  and purple for High Power; thin outlines and readable symbols.
- Neutral macOS hover highlights replace colored row backgrounds.
- Publisher supports versioned updates to the existing Homebrew tap.

Verification: 171 executable checks, actual energy query, rendered UI fixtures,
and source-matched release/helper signatures and ZIP round-trip. Development
preview remains ad-hoc signed, not notarized; fresh-install helper approval,
switching and restart persistence remain unverified.

## 0.2.0 — 2026-10-08 (development preview)

- Smaller grey menu details, tighter spacing, slimmer icons, centred High Power
  arrows, lighter purple, and automatic compact menu-bar sizing.
- Energy Mode mouse clicks keep the menu open without dimming during switching.
- Optional saved time-until-full display using macOS estimates.
- Prepared Apple Silicon ZIP/checksums, Homebrew tap cask, local MacPorts recipe,
  and optional Developer ID signing/notarization preparation.

- Wait for Service Management's asynchronous unregister completion before
  re-registering the helper. Setup now verifies an authenticated, read-only XPC
  response before reporting success. Add Terminal repair/status/connection
  diagnostics for desktop verification of failed helper registrations.

- Show the connected charger's reported wattage capability in the battery menu
  header, clearly labeled Charger capacity. Missing ratings remain unavailable,
  and unplugging clears the reading. This is not a live power measurement.

Verification: 168 checks, matched helper/client signatures, bundle verification
and ZIP extraction round-trip. The preview is ad-hoc signed; fresh-install
helper approval, switching and restart persistence are unverified for its pair.
Official package-manager acceptance and a stable notarized release are not claimed.

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
