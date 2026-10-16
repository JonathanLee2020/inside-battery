# Inside Battery handoff

Updated: 16 October 2026. There is one app build: `dist/Inside Battery.app`.

## Release 0.2.10 published — 16 October 2026

Published: https://github.com/JonathanLee2020/inside-battery/releases/tag/v0.2.10
Source commit a2164a9; tap commit 434e948. Release branch pushed; non-main tap
tracking branch fast-forwarded. All five assets published; signed update-feed
reports 0.2.10. Downloaded public ZIP matches manifest checksum; public feed bytes
match the verified signed feed. Real local 0.2.8 SPUUpdater received and parsed
0.2.10; no installation attempted during this diagnostic.

User requested a release of all five sprite rows, then requested a tiny size
increase before publication and a record of the existing size as Small.
Branch release/v0.2.10; version 0.2.10/build 12. Current sprites are 20x26pt in
30pt rows. Small remains documented below as 18x24pt in 28pt rows, with a saved
preview at dist/design/theme-sprites-small-18x24.png. No size preference UI added.

Includes Piplup edge cleanup, purple Joey, actual Turtwig and Chimchar animations,
and Yoshi isolated without egg/background. Only the four source GIFs used by the
preparation scripts are included from assets. Unused GIF experiments and .vscode
settings remain untracked and excluded from the release commit.
375 bundled checks passed before/after ZIP extraction. Bundle signatures, helper
pinning and all five bundled sprite byte comparisons passed. Public helper/client
and pinned hash are byte-identical to 0.2.9.
Archive: dist/releases/v0.2.10/InsideBattery-0.2.10-arm64.zip.
SHA256: 733cdb3b5040352c0063e8619cd68464cd308869ef8ca8617b1cbd55eaac8155.

Initial prepare-release.sh exited 1 at feed signing: default Homebrew Python 3.15
cannot load pyexpat (missing _XML_SetAllocTrackerActivationThreshold in system
libexpat). The archive and verification had already completed. Kept the archive
and finished signed-feed preparation with installed /opt/local/bin/python3.13;
archive checksum reverified unchanged. Both release scripts now accept
RELEASE_PYTHON, and publication uses Python 3.13. No system Python changes made.
Build/failure log: .build/release-0.2.10-verification.log.
Recovery log: .build/release-0.2.10-feed-recovery.log.

Slightly larger sprites installed locally after user confirmed quit. 375 installed
checks/signatures passed, working helper/client unchanged; app reopened (PID 34415).
Stage: .build/interface-updates/theme-sprites-larger-helper-preserved.fttu970s/Inside Battery.app.
Backup: .build/rollback-backups/interface-install.5I8wa5/Inside Battery.app.
Local working app retains 0.2.8 metadata. Public release is a separate fresh bundle.
Fresh-install helper approval and actual package installation remain unverified.

## Theme sprite size reference — 16 October 2026

User requested a tiny size increase before releasing and asked to preserve the
previous size under the name Small. These are display bounds in macOS points;
source GIF pixels and animation timing are unchanged. Aspect ratio is preserved.

| Reference | Sprite bounds | Menu row height | Sprite origin |
| --- | --- | --- | --- |
| Small (saved baseline) | 18×24pt | 28pt | x150, y2 |
| Slightly larger (current trial) | 20×26pt | 30pt | x150, y2 |

Small preview saved at dist/design/theme-sprites-small-18x24.png.
To restore Small, set the ThemeSpriteRow frame height to 28 and spriteView bounds
to 18×24; keep its x150/y2 origin. No user-facing size setting was added.

## Chimchar and isolated dancing Yoshi sprites installed — 16 October 2026

User requested the same compact animated treatment for Chimchar and Yoshi,
explicitly excluding Yoshi's egg/background. Found reorganized assets:
assets/chimchar/chimchar-sprite.gif (140 frames, 50ms, 41x55, already transparent)
and assets/yoshi/yoshi-tv-yoshi-bailando.gif (10 frames, 100ms, 220x220). The
other Yoshi running GIF was not used. Updated Piplup preparation source path
for user-reorganized assets/piplup/piplup-sprite.gif.

scripts/prepare-extra-theme-sprites.py writes Resources/ChimcharTheme.gif and
Resources/YoshiTheme.gif. Chimchar's original 140 frames/opaque pixels/alpha
verified exact. Yoshi masks the muted green background from the frame edges,
then retains the largest connected foreground component (Yoshi) and discards
the separate egg. All 10 frames inspected on a dark contact sheet, full character
retained with no egg/background. Shared crop canvas 117x182 prevents frame jitter.
Both outputs retain timing/loop and have zero palette error against prepared frames.

App menu loads both into the same 18x24pt sprite/28pt row as the earlier themes.
Build/installer copy all five GIFs; bundled self-tests cover each frame count.
README/CHANGELOG updated. Release build and staged/installed signatures passed;
375 installed self-checks passed. All five sprite rows passed accessible-name and
action-dispatch harness; actual row render inspected (.build/theme-sprite-rows.png).
No live menu playback click-through claimed (Computer Use unavailable previously).
Installed after user confirmed quit; original helper/client unchanged, app
restarted (PID 32144). Stage:
.build/interface-updates/chimchar-yoshi-sprites-helper-preserved.2oggbr1i/Inside Battery.app.
Backup: .build/rollback-backups/interface-install.ajI9en/Inside Battery.app.
Build log: .build/chimchar-yoshi-sprites-build.log.
No release/commit/push requested; local bundle metadata remains 0.2.8.

## Piplup pale matte edge removed — 16 October 2026

User reported white background clipping on Piplup. Reproduced on enlarged
per-frame dark-background previews: the pure white backdrop was transparent,
but edge-connected pale blue-grey (189/205/222) matte remained in the sprite.
Updated scripts/prepare-piplup-sprite.py with an eight-connected exterior matte
cleanup before recoloring. It stops at solid white details, retaining every
white face/belly pixel. Removed 217 matte pixels in frame 0 and 206 in frame 1.
All other RGB values, both frames, 280ms timing/loop retained with zero palette
error. Regenerated both Piplup and its derived purple Joey variant. Turtwig unchanged.

Build passed; staged/installed bundles passed 371 self-checks. All three sprite
rows passed accessible-name/theme-action harness; actual row render inspected
(.build/theme-sprite-rows.png). No live menu playback click-through claimed.
Installed after user confirmed quit; signatures valid, helper/client unchanged;
app restarted (PID 29961). Stage:
.build/interface-updates/piplup-edge-cleanup-helper-preserved.4h20jvfq/Inside Battery.app.
Backup: .build/rollback-backups/interface-install.etEvfo/Inside Battery.app.
Build log: .build/piplup-edge-cleanup-build.log.
No release/commit/push requested; local bundle metadata remains 0.2.8.

## Transparent Turtwig menu sprite installed — 16 October 2026

User requested the same sprite treatment for turtwig. Found actual new source
assets/turtwig-sprite.gif and used Turtwig rather than recoloring Piplup.
Resources/TurtwigTheme.gif replaces visible turtwig text in the same 18x24pt
sprite view/28pt row. Accessible name, swatches and selection action retained.
Source unchanged: 84 frames, 60ms each, looping; output cropped to 205x277.

Extracted shared preparation into scripts/theme_gif.py. Reproduce Turtwig with:
/opt/local/bin/python3.13 scripts/theme_gif.py assets/turtwig-sprite.gif Resources/TurtwigTheme.gif 240
The 240 cutoff removes edge-connected off-white background while preserving
interior details. Initial octree conversion failed the pixel-preservation check;
exact palette attempt then rejected frames with 256 opaque colors (a transparency
slot needs one of those 256 entries). Final encoder uses exact indexed colors and
only merges nearest shades where needed, rejecting errors >8/255; actual maximum
error is 5/255. All 84 frames, timing, loop and alpha verified. Regenerated Piplup
and Joey through the shared helper: both retain zero pixel error and timing.
Build/installer and bundled frame-count checks now include Turtwig.

Release build passed 365 source self-checks; staged/installed bundles passed 371.
All three sprite rows passed accessible-name/theme-action harness. Actual row
render inspected: .build/theme-sprite-rows.png. Live menu playback remains
unverified through Computer Use (unavailable on preceding turns).
Installed after user confirmed quit; valid signatures and unchanged helper/client;
app restarted (PID 27574). Stage:
.build/interface-updates/turtwig-sprite-helper-preserved.pq9gh3h8/Inside Battery.app.
Backup: .build/rollback-backups/interface-install.xepWp9/Inside Battery.app.
Build log: .build/turtwig-sprite-build.log.
No release/commit/push requested; local bundle metadata remains 0.2.8.

## Smaller Piplup and purple Joey sprites installed — 16 October 2026

User requested smaller Piplup and corresponding blue-to-purple shades for Joey.
Both menu sprites now 18x24pt (was 30x38); row height 28pt (was 44). Piplup keeps
its blue sprite; Joey gets a purple variant in place of visible text. Test Joey
retains its text. Accessible names, swatches, state and selection action retained.
scripts/prepare-piplup-sprite.py now writes Resources/JoeyTheme.gif as well as
PiplupTheme.gif. Blue hues 180–240 degrees shift +75 degrees, preserving HSV
saturation/value and all non-blue colors/alpha. Both two-frame GIFs preserve
280ms timing and looping. Independent color check verifies only blue pixels
changed. Build/installer copy both GIF resources; bundled checks cover both.

Release build passed 365 source checks; staged/installed apps passed 369.
Row action/accessibility harness passed; actual row rendering inspected at
.build/piplup-menu-row.png. Live menu playback not clicked through (Computer
Use was unavailable on preceding turn). Installed after user confirmed quit;
signatures valid, original helper/client unchanged; app restarted (PID 24768).
Stage: .build/interface-updates/joey-purple-sprite-helper-preserved.4k0pex9u/Inside Battery.app.
Backup: .build/rollback-backups/interface-install.yvWKk0/Inside Battery.app.
Build log: .build/joey-purple-sprite-build.log.
No release/commit/push requested; local bundle metadata remains 0.2.8.

## Transparent animated Piplup theme row installed — 16 October 2026

User requested the source assets/piplup-sprite.gif transparent and in place of
Piplup text. User explicitly selected frame-by-frame GIF processing to retain
animation. Source remains unchanged. scripts/prepare-piplup-sprite.py (Pillow,
verified with /opt/local/bin/python3.13) removes only edge-connected white and
crops the shared sprite bounds. Output Resources/PiplupTheme.gif: 68x88, two
frames, 280ms each, original looping. Both frames' opaque pixels/timing verified
unchanged; white character details preserved. Default python lacks Pillow;
MacPorts Python 3.13 has Pillow 12.2.0. Initial getdata deprecation fixed using
get_flattened_data, and conversion verification rerun without warnings.

ThemeSpriteRow uses an animated NSImageView instead of visible Piplup text,
retaining swatches, checkmark, accessible Piplup label and selection action.
44pt Piplup row, 30x38 sprite. Bundle resource loading reports missing/invalid
assets explicitly during menu construction. Build/installer scripts copy GIF.
Bundled self-tests now verify resource decoding and two animation frames.
README/CHANGELOG updated. No release/commit/push requested.

Release build passed 365 source self-checks; staged/installed bundles passed 367.
Standalone row harness verified accessible name and theme action dispatch.
Actual NSView light/dark render inspected: .build/piplup-menu-row.png.
Live Computer Use inspection timed out (-10005), so live menu playback/click-through
was not verified. User should open Themes to inspect animation in the live menu.
Installed after user confirmed quit; signatures valid, helper/client unchanged,
app restarted (PID 23306). Stage:
.build/interface-updates/piplup-sprite-helper-preserved.4mrwdo9o/Inside Battery.app.
Backup: .build/rollback-backups/interface-install.zTZVTN/Inside Battery.app.
Build log: .build/piplup-sprite-build.log. Local bundle version remains 0.2.8;
published 0.2.9 does not contain this new sprite row.

## Release 0.2.9 published — 13 October 2026

Published: https://github.com/JonathanLee2020/inside-battery/releases/tag/v0.2.9
Source commit 328e92f; tap commit 72117ba. Release branch pushed; non-main tap
tracking branch fast-forwarded. All five assets published; signed update-feed
reports 0.2.9. Downloaded public ZIP matches manifest checksum; public feed bytes
match the verified signed feed. Real local 0.2.8 SPUUpdater received and parsed
0.2.9; no installation attempted during this diagnostic.

User requested release of Test Joey's shared darker grey Automatic border.
Branch release/v0.2.9; version 0.2.9/build 11. Test Joey uses the same black-at-35%
Automatic outline as Yoshi and the other themes, with its existing 1.75pt width.
Release notes: packaging/releases/v0.2.9.md. Unrelated untracked
assets/piplup-sprite.gif remains excluded from the release commit.

365 checks passed before/after ZIP extraction. Bundle signatures, helper/client
pinning, signed archive/feed, and ZIP round-trip passed. Public helper/client and
pinned hash are byte-identical to 0.2.8.
Archive: dist/releases/v0.2.9/InsideBattery-0.2.9-arm64.zip.
SHA256: c9cb1602b5bd19f20e004fb89c7f4004fc042fbd93c4cc22f8a7a073ba4941e2.
Build log: .build/release-0.2.9-verification.log.
Local running app already has the darker border, retaining 0.2.8 bundle metadata
and original working helper pair. Release packaging does not replace that app.
Fresh-install helper approval and actual package installation remain unverified.

## Test Joey shared darker grey border installed — 13 October 2026

User clarified Test Joey should use Yoshi/other themes' darker Automatic border.
Replaced explicit light grey RGB 0.61/0.61/0.63 with the shared outline(for: .automatic)
color (black at 35% opacity); retained 1.75pt width. Fill and Low/High unchanged.
Release build passed 365 checks; renderer preview regenerated/inspected.
Stage signatures valid:
.build/interface-updates/test-joey-dark-border-helper-preserved.13zjoixs/Inside Battery.app.
Build log: .build/test-joey-dark-border-build.log. Installed after user confirmed quit.
Installer preserved original helper/client; signatures and 365 installed checks
passed. App restarted (PID 5149). Backup:
.build/rollback-backups/interface-install.C8sVCt/Inside Battery.app.
No new release/commit/push requested.

## Release 0.2.8 published — 13 October 2026

Published: https://github.com/JonathanLee2020/inside-battery/releases/tag/v0.2.8
Source commit c5759f9; tap commit 803e3e8. Release branch pushed; non-main tap
tracking branch fast-forwarded. All five assets published; signed update-feed
reports 0.2.8. Downloaded public ZIP matches manifest checksum; public feed bytes
match the verified signed feed. Real local 0.2.8 SPUUpdater received and parsed
the signed feed; no installation attempted during this diagnostic.

User requested Test Joey after all existing themes, then a new release. Test Joey
uses the current Joey purple fills (0.80/0.62/0.86 Automatic/Low, 0.78/0.60/0.84
High) with the previously refined darker grey Automatic border RGB 0.61/0.61/0.63
at 1.75pt. Joey retains its matching purple Automatic border. Low/High border
colors remain shared. Test Joey is saved independently under raw ID testJoey.
Branch release/v0.2.8; version 0.2.8/build 10. Untracked assets/piplup-sprite.gif
is unrelated and excluded from the release commit.

365 self-checks passed before/after ZIP extraction, including all six themes'
contrast/rendering/width matrix and Test Joey's final ordering/distinct border.
Renderer preview regenerated/inspected: dist/design/themes-preview.png.
Bundle signatures, helper/client pinning, signed archive/feed and ZIP round-trip
passed. Public helper/client/hash are byte-identical to 0.2.7.
Archive: dist/releases/v0.2.8/InsideBattery-0.2.8-arm64.zip.
SHA256: 6a1131e65682fcb8b9089b9a35427618e4ff9eec7a233abf756fcd3063d4abae.
Build log: .build/release-0.2.8-verification.log.
Local preserved-helper stage: .build/interface-updates/v0.2.8-helper-preserved.sbvd883l/Inside Battery.app.
Installed after user confirmed quit; original helper/client unchanged, signatures
valid, installed executable passed 365 checks and app reopened.
Backup: .build/rollback-backups/interface-install.arykNa/Inside Battery.app.
Fresh-install helper approval and actual package installation remain unverified.

## Joey medium purple installed — 13 October 2026

User found Joey still too pale. Automatic/Low now RGB 0.80/0.62/0.86 and High
0.78/0.60/0.84, replacing 0.86/0.75/0.89 and 0.84/0.73/0.87. Automatic border
tracks the new purple at 1.75pt. Details/README/CHANGELOG updated.
The existing charge/remainder check assumed fill was brighter; it now verifies
the same >=1.1 contrast ratio using max/min luminance so darker fills are valid.
All 334 checks pass, including numeral contrast and slightly darker High Power.
Renderer preview regenerated/inspected. Stage signatures valid:
.build/interface-updates/joey-medium-purple-helper-preserved.ja_kj5fv/Inside Battery.app.
Build log: .build/joey-medium-purple-build.log. Installed after user confirmed quit.
Installer preserved original helper/client; signatures and 334 installed checks
passed. App restarted (PID 2518). Backup:
.build/rollback-backups/interface-install.iG6Ep5/Inside Battery.app.
No release/commit/push requested.

## Joey lavender Automatic border installed — 13 October 2026

User requested Joey's purple fill as the border instead of grey and had quit.
Joey Automatic border now uses progress(for: mode), matching lavender RGB
0.86/0.75/0.89, at the existing 1.75pt width. Low/High borders unchanged.
Release build and installed executable passed 334 checks. Renderer preview
regenerated/inspected; signatures valid and original helper/client unchanged.
App restarted (PID 1289). Stage:
.build/interface-updates/joey-purple-border-helper-preserved.gdne25q8/Inside Battery.app.
Backup: .build/rollback-backups/interface-install.5K7rLh/Inside Battery.app.
Build log: .build/joey-purple-border-build.log. No release/commit/push requested.

## Joey darker lavender installed — 13 October 2026

User requested Joey slightly darker in all modes while retaining darker High Power.
Automatic/Low RGB changes from 0.87/0.76/0.90 to 0.86/0.75/0.89; High changes
from 0.85/0.74/0.88 to 0.84/0.73/0.87. Refined Automatic border retained.
Release build and installed executable passed 334 checks, including contrast and
High luminance below Automatic/Low. Renderer preview regenerated/inspected.
Installed after user confirmed quit; signatures valid, helper/client unchanged,
app restarted (PID 395). Stage:
.build/interface-updates/joey-darker-fill-helper-preserved.brevjjxo/Inside Battery.app.
Backup: .build/rollback-backups/interface-install.z1RMg8/Inside Battery.app.
Build log: .build/joey-darker-fill-build.log. No release/commit/push requested.

## Joey Automatic border refinement installed — 13 October 2026

User requested a tiny reduction in Joey Automatic border thickness and slightly
darker grey, still lighter than the original. Border changes from 2pt RGB
0.64/0.64/0.66 to 1.75pt RGB 0.61/0.61/0.63. Low/High and other themes unchanged.
Updated border-width matrix for intentional Joey Automatic exception.
Release build passed 334 self-checks. Renderer preview regenerated/inspected.
Stage signatures verified:
.build/interface-updates/joey-refined-border-helper-preserved.6pva9y9t/Inside Battery.app.
Build log: .build/joey-refined-border-build.log. Installed after user confirmed quit.
Installer preserved original helper/client; signatures and 334 installed self-checks
passed. App restarted (PID 99209). Backup:
.build/rollback-backups/interface-install.BYEg0O/Inside Battery.app.
No release/commit/push requested.

## Joey lighter grey Automatic border installed — 13 October 2026

User found Joey's grey border too dark and had quit. Joey Automatic border now
uses opaque light grey RGB 0.64/0.64/0.66 instead of black at 35% opacity.
Thickness remains 2pt. Low/High colored outlines and other themes unchanged.
Release rebuild and installed executable passed 334 self-checks. Actual renderer
preview regenerated/inspected: dist/design/themes-preview.png. Signatures valid;
installer preserved original helper/client byte-for-byte. App restarted (PID 98459).
Stage: .build/interface-updates/joey-light-border-helper-preserved.5ipsy_sx/Inside Battery.app.
Backup: .build/rollback-backups/interface-install.4UUaoS/Inside Battery.app.
Build log: .build/joey-light-border-build.log. No release/commit/push requested.

## Joey slightly darker High Power installed — 13 October 2026

User requested Joey High Power slightly darker than Automatic. High fill is now
RGB 0.85/0.74/0.88 versus Automatic/Low 0.87/0.76/0.90. Updated shared-fill
invariant to verify Joey Low remains equal and High luminance decreases by less
than 10% on both power sources. README/CHANGELOG updated.
Build and installed executable passed 334 checks, including contrast. Actual
renderer preview regenerated/inspected: dist/design/themes-preview.png.
Installed after user confirmed quit; signatures passed, original helper/client
unchanged; app restarted (PID 97602). Stage:
.build/interface-updates/joey-high-helper-preserved.7osfl3fg/Inside Battery.app.
Backup: .build/rollback-backups/interface-install.QCmbob/Inside Battery.app.
Build log: .build/joey-high-build.log. No release/commit/push requested.

## Release 0.2.7 published — 13 October 2026

Published: https://github.com/JonathanLee2020/inside-battery/releases/tag/v0.2.7
Source commit d015fbf; tap commit 315360d. Release branch pushed; non-main tap
tracking branch fast-forwarded. Five assets published; signed update-feed now
reports 0.2.7. Downloaded public ZIP matches manifest SHA-256; public feed bytes
match the verified signed feed. Real local 0.2.6 SPUUpdater received and parsed
0.2.7; no installation attempted during this diagnostic.

User requested release of the separate Themes section, cooler Piplup, and soft-red
Chimchar. Branch release/v0.2.7; version 0.2.7/build 9. Untracked
assets/piplup-sprite.gif remains unrelated and excluded from the release commit.

332 executable self-checks passed before/after ZIP extraction. Bundle signatures,
helper/client pinning, signed archive/feed, and ZIP round-trip passed. Public
helper/client and pinned hash are byte-identical to 0.2.6.
Archive: dist/releases/v0.2.7/InsideBattery-0.2.7-arm64.zip.
SHA256: a472bd327db825cf57cf4019fd3611da7a024171451757f77cb9a1b8c6d96d5b.
Build log: .build/release-0.2.7-verification.log.
Fresh-install helper approval and actual package installation remain unverified.
Local running app has the new colors/section and 0.2.6 metadata; release packaging
does not replace the local working helper pair or restart that app.

## Chimchar soft red installed — 13 October 2026

User found coral too orange. Reduced green from 0.66 to 0.52, keeping red 0.93
and blue 0.52: Chimchar is now soft red. Updated detail/README/CHANGELOG.
Release rebuild and installed executable passed 332 checks, including contrast.
Installed after user confirmed quit; signatures valid, helper/client unchanged,
app reopened (PID 95168). Stage:
.build/interface-updates/chimchar-red-helper-preserved.qj6yfi3p/Inside Battery.app.
Backup: .build/rollback-backups/interface-install.244fGH/Inside Battery.app.
Build log: .build/chimchar-red-build.log. No release/commit/push requested.

## Piplup and Chimchar colors installed — 13 October 2026

User requested Piplup slightly darker/bluer and Chimchar slightly darker/redder
so it is distinct from Low Power yellow. Piplup RGB changes from 0.65/0.89/0.91
to 0.57/0.82/0.90. Chimchar changes from 0.97/0.78/0.60 to 0.93/0.66/0.52.
Theme details and README now describe cool blue and coral. Themes section retained.
Release rebuild passed 332 checks, including percentage contrast in both appearances.
Actual renderer preview regenerated and inspected: dist/design/themes-preview.png.
Stage signatures passed:
.build/interface-updates/piplup-chimchar-helper-preserved.a3w5j9iw/Inside Battery.app.
Build log: .build/piplup-chimchar-build.log. Installed after user confirmed quit.
Installer verified original helper/client unchanged; installed executable passed 332
checks and app restarted (launchctl PID 93860). Backup:
.build/rollback-backups/interface-install.kJfxSC/Inside Battery.app.
No new release, commit or push requested for these changes.

## Themes section installed — 13 October 2026

User requested Themes as its own section, like energy data. Added a native separator
above Themes; existing separator before Quit encloses the Themes submenu row.
Release rebuild and installed executable passed 332 self-checks. Installer verified
signatures and original helper/client byte-for-byte unchanged. App quit gracefully
and reopened after installation. Stage:
.build/interface-updates/themes-section-helper-preserved.ivag1ev1/Inside Battery.app.
Backup: .build/rollback-backups/interface-install.JTab9f/Inside Battery.app.
Build log: .build/themes-section-build.log. Computer Use inspection timed out
(-10005); live menu click-through was not verified. README/CHANGELOG updated.
Local bundle now has 0.2.6 metadata. Published 0.2.6 does not include this section.

## Release 0.2.6 published — 13 October 2026

Published: https://github.com/JonathanLee2020/inside-battery/releases/tag/v0.2.6
Source commit c07cc86; tap commit 4c94cba. Release branch pushed; non-main tap
tracking branch fast-forwarded. All five assets published; signed update-feed
now reports 0.2.6. Downloaded public ZIP matches the manifest SHA-256, and public
feed bytes match the verified signed feed. Real local 0.2.5 SPUUpdater received
and parsed 0.2.6; no installation attempted by the diagnostic.

User requested a new release of the current verified changes. Branch release/v0.2.6;
version 0.2.6/build 8. Includes renamed themes with stable saved IDs, warmer Joey,
green turtwig, mode-dependent Yoshi fills/green accessories and uniform 2pt borders.
Release notes: packaging/releases/v0.2.6.md. Existing untracked assets/piplup-sprite.gif
is unrelated and excluded from publication.

332 self-checks passed before and after ZIP extraction. Full bundle signatures,
helper/client pinning, signed Sparkle archive/feed and archive round-trip passed.
Public helper/client and pinned hash are byte-identical to 0.2.5.
Archive: dist/releases/v0.2.6/InsideBattery-0.2.6-arm64.zip.
SHA256: 3e8f8a92b038f4a7cb6d9530ebcf9b7c40866d106de9d15841b30313b95445a8.
Build log: .build/release-0.2.6-verification.log.
Fresh-install helper approval and actual package installation remain unverified.
Local running app retains its original helper pair and 0.2.5 bundle metadata.

## Theme names installed — 13 October 2026

User renamed Meadow to `turtwig`, Tidepool to Piplup, and Ember to Chimchar
in BatteryTheme.swift and requested docs, rebuild and restart. README now uses
these display names; CHANGELOG records the rename. Published release notes and
older handoff entries retain their historical names.

Initial build failed because SelfTest still referenced BatteryTheme.meadow.
Updated references to turtwig. Renamed enum cases retain the old raw preference
IDs (`meadow`, `tidepool`, `ember`) so existing selections survive; three isolated
preference checks verify this. Theme order and user-entered capitalization retained.

Release rebuild and installed executable passed 332 self-checks. Deep/strict
bundle signature verification passed. Installer preserved original helper/client
byte-for-byte and backed up the previous bundle. Its sandboxed launch failed with
kLSNoExecutableErr; reopening outside the sandbox succeeded, and launchctl
confirmed the app running (PID 84802).
Stage: .build/interface-updates/theme-renames-helper-preserved.1jjgh_jg/Inside Battery.app.
Backup: .build/rollback-backups/interface-install.IGWe1B/Inside Battery.app.
Build log: .build/theme-renames-build.log.
No commit, push or release requested. Live menu click-through was not performed.

## Uniform borders and green Yoshi Automatic installed — 13 October 2026

User requested every theme's battery borders at the same thickness and Yoshi
Automatic green while charging. All menu-bar outlines now 2pt: grey Automatic,
gold Low, dark-purple High, in every theme and on both power sources. Energy
Mode menu icons retain their separate native 1pt outlines. Yoshi Automatic fill
is green (0.55/0.87/0.65) on both power sources; bright yellow Low and lavender
High fills are unchanged. Green charging accessories retained.

329 checks passed, including every theme/mode/power-source border width and
Yoshi external-power green. Signatures and actual renderer preview verified.
Turn was interrupted after successful verification; resumed by staging existing
verified build without repeating implementation. Preserved-helper stage:
.build/interface-updates/uniform-borders-helper-preserved.uuwbmg8c/Inside Battery.app.
Installed after user confirmed quit. App reopened; installed self-checks passed
329. Original helper/client verified unchanged. Backup:
.build/rollback-backups/interface-install.lyUBsA/Inside Battery.app.
Build log: .build/uniform-borders-build.log.
No release/commit/push requested. GitHub 0.2.5 remains unchanged.

## Warm Joey and slightly darker High Power installed — 12 October 2026

User requested slightly warmer/yellower Joey lavender, a slightly darker High
Power purple and bolder outlines. Joey fill changes from 0.85/0.74/0.95 to
0.87/0.76/0.90. Yoshi High fill changes from the menu circle lavender to slightly
deeper 0.82/0.65/0.94; Low retains the circle's native yellow. Menu-bar gold/purple
outlines increase from 1.75pt to 2pt. Automatic thin/no outlines unchanged.
Energy Mode circles and 1pt native-style battery outlines remain unchanged.

301 checks and signatures passed. Prior exact High circle-fill equality updated
to assert a modest luminance reduction while preserving readable percentage text.
Actual renderer preview regenerated: dist/design/themes-preview.png.
Stage: .build/interface-updates/warm-lavender-helper-preserved.qtxt_r75/Inside Battery.app.
Installed after user confirmed quit; app reopened and installed checks passed 301.
Original helper/client verified unchanged. Backup:
.build/rollback-backups/interface-install.LVSBOO/Inside Battery.app.
Build log: .build/warm-lavender-build.log. No release requested.

## Brighter Yoshi mode fills installed — 12 October 2026

User wanted Low Power to match the selected circle's native yellow, and High
Power purple lighter. Yoshi Low/High now use the same colors as their original
Energy Mode circles: systemYellow and lavender (0.86/0.69/0.98). Deeper gold/dark
purple borders retained. High returns to black numerals and grey empty area
(0.62/0.62/0.66) for readable partial charge. Automatic and Meadow unchanged.
301 checks and signatures passed; changed prior exact border-fill equality check
to circle-fill equality for Low/High on both power sources. Preview regenerated.
User already quit, so no question. Staged/installed with original helper/client
unchanged; app reopened and installed self-checks passed 301.
Stage: .build/interface-updates/yoshi-bright-helper-preserved.e6_j7_oy/Inside Battery.app.
Backup: .build/rollback-backups/interface-install.ZLFDmB/Inside Battery.app.
Build log: .build/yoshi-bright-build.log. No release/commit/push requested.

## Yoshi mode fills and Meadow green installed — 12 October 2026

User clarified Yoshi Low/High should match border colors. Yoshi Automatic remains
green on battery and purple on external power; Low fills exactly the gold outline
color (0.78/0.57/0.08), High exactly the dark purple outline (0.48/0.24/0.69).
High uses white numerals and dark-grey empty area for >=4.5:1 contrast across
filled/empty areas. Green accessories and thin unplugged Automatic outline remain.
Meadow stays green in every mode and on both power sources. Menu circles unchanged.
Updated prior shared-fill invariant to reflect intentional Yoshi mode differences;
301 checks passed, including actual palette contrast, saved themes and match of
Low/High fill with outline on both power sources. Preview regenerated from renderer.

User had already quit; no repeated question. Preserved-helper stage:
.build/interface-updates/yoshi-modes-helper-preserved.d496c9vg/Inside Battery.app.
Installed/reopened; installed self-checks passed 301, original helper/client unchanged.
Backup: .build/rollback-backups/interface-install.WLxKfJ/Inside Battery.app.
Build log: .build/yoshi-mode-build.log. Source change only; no new release requested.

## Yoshi power-state adjustment installed — 12 October 2026

User clarified Yoshi: green Automatic on battery, purple while connected,
original subtle border when off charger, green lightning/plug accessories.
Interpreted border request as restoring the original 0.75pt black-at-35% outline
for Yoshi Automatic on battery power; explicit Low gold / High purple borders
remain 1.75pt. Connected includes active and paused charging. Green charge fill
(0.55/0.87/0.65) and purple connected fill (0.81/0.64/0.91); remainder grey.
Accessory green is bright (0.35/0.95/0.50) in dark appearance and deeper
(0.07/0.52/0.25) in light appearance for >=3:1 contrast. Other themes unchanged.
Energy Mode menu circles/outlines unchanged. No new release requested.

Build, signature validation and 299 self-checks passed. Added tests for Yoshi
power-source colors, thin unplugged outline and accessory color/contrast.
Actual rendering preview: dist/design/yoshi-power-preview.png.
Preserved-helper stage: .build/interface-updates/yoshi-power-helper-preserved.cut6nlbz/Inside Battery.app.
Installed after user confirmed quit. App reopened; installed self-checks passed
299. Original helper/client verified unchanged. Backup:
.build/rollback-backups/interface-install.3xzoRf/Inside Battery.app.
Build log: .build/yoshi-power-build.log.
GitHub 0.2.5 remains the published yellow/purple Yoshi version until a new release.

## Published themes release — 0.2.5

Published: https://github.com/JonathanLee2020/inside-battery/releases/tag/v0.2.5
Source commit 05f273a; tap commit 226e7cb. App release branch pushed; non-main tap
default branch fast-forwarded. All five assets uploaded; signed update-feed
updated to 0.2.5. Public ZIP checksum and signatures verified. Real 0.2.4 Sparkle
probe received/parsed 0.2.5; no installation attempted during the probe.
Homebrew fetch/dry run passed; MacPorts lint 0 errors/0 warnings (definitions old).
User explicitly requested release publication through Sparkle. Branch release/v0.2.5;
version 0.2.5/build 7. Includes all previously local theme/menu/outline changes.
Theme title now 💜 Joey 💜 (saved raw ID remains joey). Yoshi uses yellow progress
(0.95/0.83/0.42) and light-purple remainder (0.81/0.64/0.91), unchanged across
energy modes. Menu-bar gold/purple outlines and original Energy Mode circles
retained. Preferences/Themes top-level arrangement is included in the download.

291 executable checks passed before/after archive extraction, nested signatures,
helper pinning and signed feed/archive preparation passed. Public helper, client
and pinned hash compared byte-for-byte against 0.2.4 ZIP: all identical, ensuring
compatibility with the registered public helper pair.
Archive: dist/releases/v0.2.5/InsideBattery-0.2.5-arm64.zip.
SHA256: a805d49b5f01792ca9651f62110aea7f470cc401712dc8f9fa885aba32d6e19c.
Build log: .build/release-0.2.5-verification.log.
Local preserved-helper stage passed 291 checks and signatures:
.build/interface-updates/v0.2.5-helper-preserved.x4p3fop8/Inside Battery.app.
Installed after user confirmed quit. App reopened as 0.2.5; installed executable
passed 291 checks. Installer verified original helper/client byte-for-byte unchanged.
Backup: .build/rollback-backups/interface-install.MOIZ9o/Inside Battery.app.
Public app and local retained helper pairs still differ; no service registration
or root service replacement was performed for the local update.

## Restored Energy Mode icons and deeper outlines — 12 October 2026

User clarified that Energy Mode menu icons should retain their original colors
and uniform thin outlines. Restored fixed blue Automatic, system yellow Low and
light lavender High selected circles, white Automatic/dark Low/High symbols,
1pt native-style battery outlines, short Low fill and High fast-forward triangles.
This styling is independent of the selected theme. Menu-bar fill remains shared
across energy modes. Low outline is now deeper gold (0.78/0.57/0.08), High keeps
dark purple; both menu-bar outlines are 1.75pt (previously 1.25pt). Automatic
menu-bar has no outline. Preferences/Themes layout and saved themes retained.

291 checks and nested signatures passed, including restored rasterized circles,
percentage contrast and deeper-gold check. Preview regenerated in both appearances.
Prepared stage retains original helper/client:
.build/interface-updates/gold-outline-helper-preserved.dw_nosmh/Inside Battery.app.
Installed after user confirmed quit; app reopened and installed executable passed
291 checks. Original helper/client unchanged. Backup:
.build/rollback-backups/interface-install.dRDxBp/Inside Battery.app.
Build log: .build/gold-outline-build.log.
No release, commit or push requested.

## Installed menu and outline update — 12 October 2026

User moved Themes out of the app submenu: renamed Inside Battery to Preferences;
Themes is now the next top-level row, with an original 18pt four-color grid icon.
Energy mode affects only the outline: Automatic none, Low yellow, High dark
purple. Selected theme controls one common fill/remainder/text across modes.
Menu mode icons also share their interior/circle color and differ by outlines;
removed High arrows and Low short-fill glyphs to satisfy border-only styling.
Meadow retains original grey/adapter-green fill but uses the shared mode outlines.
Five saved theme names remain unchanged. No version publication requested.

First executable check failed on the outdated expectation that selected Low
Power had a separate warm circle color. Updated that expectation to the shared
Joey circle and verified all 291 checks. Added invariants for shared theme fill
on both power sources, outline presence and four-color icon rendering.
Rendering preview confirmed identical interiors with mode outlines in light/dark.
Build, signature and preserved-helper stage passed:
.build/interface-updates/theme-outlines-helper-preserved.y2v9qa9b/Inside Battery.app.
Installed after user quit; app reopened, original helper/client unchanged and
installed self-checks passed 291. Backup:
.build/rollback-backups/interface-install.aA9u2s/Inside Battery.app.
Build log: .build/themes-outline-build.log. No live UI automation was repeated
because the preceding Computer Use app inspection had timed out.

## Themes installed — 12 October 2026

User requested saved themes with swatch rows resembling the supplied screenshot.
BatteryTheme defines five presets: Joey 💜 (default, current 0.2.4 purple colors),
Meadow (pre-purple grey/AC green + yellow Low + light violet High and blue
Automatic selection), Yoshi (mint/lime/forest), Tidepool (sea glass/sand/teal),
Ember (apricot/cream/terracotta). Six swatches show battery Automatic, adapter
Automatic, Low, High, empty remainder and digits; some palettes repeat colors.
AppDelegate has Inside Battery > Themes, native checked rows and swatch images.
Selection is stored in UserDefaults batteryTheme and refreshes status/menu icons.
BatteryIcon and BatteryMenu accept an explicit theme; tests default to Joey so
actual saved user preferences do not change verification results. App icon stays
purple-and-green. No new release, commit or push requested for themes yet.

278 executable checks passed: existing regressions plus theme persistence in an
isolated preference suite, classic restoration, rendering and >=4.5:1 percentage
contrast over filled/empty areas for all five themes in both appearances.
Build/signature checks passed. Preserved-helper stage:
.build/interface-updates/themes-helper-preserved.ugcgciej/Inside Battery.app.
Installed after user confirmed quit. Original client/helper retained byte-for-byte,
app reopened; installed executable passed all 278 checks. Backup:
.build/rollback-backups/interface-install.8DhHeO/Inside Battery.app.
Native Computer Use inspection timed out (-10005), so no live menu click-through
is claimed. Source rendering and isolated saved-selection checks passed.
Preview: dist/design/themes-preview.png. Build log: .build/themes-build.log.

## Published color and app-icon release — 0.2.4

User requested publication with Sparkle notification for existing downloads.
Published: https://github.com/JonathanLee2020/inside-battery/releases/tag/v0.2.4
Source commit b3009a9; tap commit 776a67a. Branch-only app push and non-main tap
fast-forward. Public ZIP checksum and Ed25519 signature verified; signed feed
reports 0.2.4. A real 0.2.3 Sparkle probe received and parsed signed 0.2.4.
Homebrew fetch/dry run passed for 0.2.4, MacPorts lint 0 errors/0 warnings
(installed definitions are old). No actual package-manager install performed.
Branch release/v0.2.4; version 0.2.4/build 6. App icon now uses the approved B
palette (purple tile, green battery). Mode palette: Automatic light purple
(0.85/0.74/0.95), Low Power user-approved warm lavender with gold tint
(0.87/0.81/0.80), High Power dark purple (0.48/0.24/0.69). Shared colors cover
menu-bar progress and selected mode circles. Dark High Power uses white numerals
and dark empty area (0.20/0.18/0.23); accessory ink is black/white by appearance.
177 checks passed, including contrast and selected-circle raster checks. Archive
round-trip, nested signatures, exact helper pinning and signed feed passed.
SHA256: 595bb25bad99d449c61bbf7e171bbe9352fd8663ef91cd45c54fc16e2eb1f62d.
Public helper hash matches 0.2.3 exactly: 8acb282dbff5c5039604e57014ddde8ae6fd9674.
Existing public 0.2.2/0.2.3 copies with automatic checks enabled can receive this
compatible update on their next Sparkle check; notifications are not push events.
Older versions without Sparkle still need a manual upgrade.

Local stage retains original helper/client and passed 177 checks, signatures and
updater startup: .build/interface-updates/v0.2.4-helper-preserved.id3g75c5/Inside Battery.app.
After user confirmed quit, installed and reopened the local 0.2.4 app.
Original helper/client unchanged; installed self-checks passed 177. Same-mode
request completed through original helper, with full saved preferences unchanged.
Backup: .build/rollback-backups/interface-install.llfylV/Inside Battery.app.
No helper registration or root service replacement performed.
Preview: dist/design/0.2.4-mode-colors.png; renderer sources retained locally.
Build verification: .build/release-0.2.4-verification.log.

## Installed app icon update — 12 October 2026

User requested a purple app icon in the direction of Flaticon's battery 668277.
Created original AppKit vector artwork (no reference asset is bundled): a dark
rounded tile, thin pale battery outline and lavender-purple charge fill.
Resources/AppIcon.png is the 1024px preview; Resources/AppIcon.icns includes all
ten macOS representations. Regenerate with scripts/render-app-icon.swift and
iconutil. Resources/Info.plist declares CFBundleIconFile=AppIcon; build-app.sh
copies the ICNS. Interface installer now also copies the icon.
Separate source build passed 177 checks, signature validation and icon-copy
comparison. Preserved-helper stage also passed 177 checks and signatures:
.build/interface-updates/purple-app-icon.puf5ums7/Inside Battery.app.
Original main/helper/client are identical to the running local app in that stage.
After user confirmed quit, installed the icon and plist and reopened the app.
Installer verified original helper/client byte-for-byte unchanged; 177 executable
checks, complete signatures, installed ICNS comparison and native macOS icon
loading passed. Backup: .build/rollback-backups/interface-install.ZN6Ecj/Inside Battery.app.
No release, commit or push requested.
GitHub 0.2.3 archive remains unchanged; changes are under Unreleased.

## Published current release — 0.2.3

User requested a new version consolidating the current app with Sparkle.
Published: https://github.com/JonathanLee2020/inside-battery/releases/tag/v0.2.3
Source release commit affe553; tap commit 8e207e5. Branch-only app push and
fast-forward of existing non-main tap default branch; no main push.
All five assets uploaded; dedicated update-feed updated with signed 0.2.3 feed.
Public ZIP checksum/signature and feed signature/version verified. Homebrew fetch
and dry-run installation passed for 0.2.3. MacPorts lint initially rejected --dir;
ran from the recipe directory instead: 0 errors/0 warnings (definitions old).
The real Sparkle probe initially received a verified older 0.2.2 feed while
direct HTTPS requests got 0.2.3. A later check received and parsed signed 0.2.3:
Feed item: 0.2.3, helper=8acb282dbff5c5039604e57014ddde8ae6fd9674
PASS: Sparkle downloaded and parsed the signed feed; no installation attempted
It resolved without cache deletion or any override of user settings. Cache
source was not established; no product code change was needed.

Branch release/v0.2.3; version 0.2.3/build 5. No functional Sparkle change from
0.2.2. README corrected to current UI/energy behavior and installation limits.
Prepared public archive: dist/releases/v0.2.3/InsideBattery-0.2.3-arm64.zip.
SHA256: dcb147b30eca979996ec2768dac00f2943995d31cfea69dff610a3e00cccca53.
Verification: 177 checks twice (before/after ZIP), helper pinning, all nested
signatures, signed archive/feed checks. Public helper hash remains
8acb282dbff5c5039604e57014ddde8ae6fd9674, matching 0.2.2.
Full verification output: .build/release-0.2.3-verification.log.

After user quit, installed the staged main/framework/plist into the real app.
Original helper/client and pinned hash retained byte-for-byte. Stage:
.build/interface-updates/v0.2.3-helper-preserved.mhemgfur/Inside Battery.app.
Backup: .build/rollback-backups/interface-install.xYbfzL/Inside Battery.app.
Local app reopened, plist reports 0.2.3, Sparkle configuration/self-checks pass.
The retained old client lacks --check: the read-only diagnostic returned its
usage message, so no read-only connection success is claimed. Instead, applied
the already-selected AC Power Automatic mode through the old client successfully;
compared full pmset custom output before/after and confirmed no changes.
Original temporary root service remains running at PID 79954; no registration
or service replacement was performed. Fresh public installation still unverified.

Homebrew download of 0.2.2 passed fetch/dry run/checksum/signatures, but downloaded
self-check process died with SIGKILL and Gatekeeper rejected the quarantined app.
Apple Developer enrollment was discussed; no signing identity was installed or
notarization completed. No quarantine bypass was attempted.

## Published Sparkle release — 0.2.2

User explicitly requested publication after implementation and testing.
Published source commit `dd44438` on `release/v0.2.2` (no main push).
Release: https://github.com/JonathanLee2020/inside-battery/releases/tag/v0.2.2
Live feed: https://github.com/JonathanLee2020/inside-battery/releases/download/update-feed/appcast.xml
Homebrew tap commit `fad22cb`; release/v0.2.2 also fast-forwarded the existing
non-main default branch release/v0.2.0. Existing dist app and working helper
were not replaced; no review variant was launched.

Pinned Sparkle 2.10.0 using SwiftPM and Package.resolved. AppUpdater owns the
standard controller, starts scheduled checks and connects Check for Updates in
the app submenu, with main-actor KVO menu enablement. Initial build failed on a
non-Sendable menu capture; storing the menu on the main-actor object fixed it.
Resources/Info.plist is now 0.2.2/build 4, with HTTPS dedicated release-asset feed,
public Ed25519 key, signed-feed requirement, verification before extraction,
silent automatic installation disabled and profile reporting disabled.

Private signing key generated in login Keychain under account inside-battery;
never exported. Only public key is in source. Official Sparkle tools downloaded
to .build/sparkle-tools. prepare-update-feed.py signs/verifies archive and feed,
embeds release notes/version and registered-helper compatibility metadata.
AppUpdater blocks missing/different/malformed helper hashes when registered,
so in-app updates cannot silently invalidate the exact client/helper trust pair.
Helper-changing updates require manual install, still unverified.

Build script embeds and signs all nested Sparkle components; development ad-hoc
builds omit hardened-runtime library validation that requires a signing team.
Developer ID builds retain hardened runtime. Interface installer now also copies
the verified Sparkle framework and plist while retaining the original helper pair.
Release preparation generates signed appcast and license asset. Publisher would
publish versioned feed/license assets and update/create dedicated update-feed
release only when explicitly invoked for a release branch. Package.resolved is
included in the publication allowlist. Public feed is now live.

Verification: 177 checks, complete framework/app/helper signature verification,
updater startup in a separate bundle, signed archive/feed generation and ZIP
round-trip. Information-only Sparkle diagnostic downloaded/parsed both empty
and sample signed feeds on a local server, including helper metadata. A tampered
feed correctly failed signature validation. A disposable app without any power
helper then updated via the standard Sparkle window; user clicked Install and
Relaunch. Verified installed bundle version 2, valid signature and launch marker
written by version 2. Temporary test app terminated after writing its marker.
Computer Use access to the disposable app was not approved, so user performed
the clicks; no alternate UI tool bypass was attempted.
Attempt to use a standalone Sparkle CLI failed (not shipped in downloaded tools);
used SPUUpdater's checkForUpdateInformation diagnostics instead.

Prepared archive: dist/releases/v0.2.2/InsideBattery-0.2.2-arm64.zip.
SHA256: c40ea1c8905973172a5c51ab7f58c26861ab491c19b703419f79af567750dcad.
Signed feed: dist/releases/v0.2.2/appcast.xml; license: Sparkle-LICENSE.txt.
Documentation: packaging/sparkle/README.md. App remains unnotarized; the real
app's privileged-helper upgrades remain outstanding.
Public ZIP: 1286212 bytes, checksum and Ed25519 signature verified against the
public signed feed. Real Sparkle downloaded and parsed the public HTTPS feed.
Homebrew fetch of 0.2.2 passed after a fast-forward of the clean local tap.
MacPorts recipe lint: 0 errors/0 warnings; installed definitions are old.
Publication initially failed on copied license trailing whitespace; attempted
edit failed because the copied license was read-only. Made only the copied
license writable, removed whitespace without wording changes, checks passed.
Local interface stage preserves the original helper pair byte-for-byte:
`.build/interface-updates/sparkle-bootstrap.fa0s8g3g/Inside Battery.app`.
177 checks, updater startup and stage signature pass. It is NOT installed.

## Published release — 0.2.1

User authorized publishing current UI and energy-parser fixes as newest release.
Source branch `release/v0.2.1`; archive built separately from running app at
`dist/releases/v0.2.1/InsideBattery-0.2.1-arm64.zip`, 205314 bytes, SHA-256
`e9d0b3147a8976c87bce83cc89cf079fbe59c8c0af18b6234d83f5076460d84a`.
171 checks, signature pinning and ZIP round-trip pass. Homebrew recipe parses
0.2.1; MacPorts lint has 0 errors/0 warnings (installed port definitions are old).
Publisher reads plist version and can update an existing public tap. It creates
a release branch and fast-forwards an existing non-main tap default branch so
existing brew update users receive changes. No direct main push or force push.
Development-preview restrictions remain: no Developer ID/notarization or tested
fresh-install helper approval/switching/restart. Live dist helper pair unchanged.
Published prerelease: https://github.com/JonathanLee2020/inside-battery/releases/tag/v0.2.1
Release source commit `8b9baf4`; public ZIP downloaded and checksum matched.
Tap commit `0845d82` initially updated release/v0.2.1 and fast-forwarded its
existing default branch release/v0.2.0. Current default cask is 0.2.1.
Initial `brew fetch --cask` failed because the tap must be added explicitly.
After `brew tap JonathanLee2020/inside-battery`, fetch passed and cached ZIP
checksum matches. Install docs/release body now include explicit brew tap first.
No app installation performed in that verification. Current working local app
was not replaced. Both ZIP and Homebrew deliver the same development preview.

## Published release — 0.2.0

User requested downloadable versions and Homebrew/MacPorts distribution.
Prepared an Apple Silicon development-preview ZIP at
`dist/releases/v0.2.0/InsideBattery-0.2.0-arm64.zip` from the current source with
a fresh matched helper/client, separate from the working runtime pair. SHA-256:
`43e560904c309f8cbd52781ed5f4b0ff6a9782413e1be634d06f4781b3fc36dd`.
168 checks, signature tests and archive extraction round-trip pass. MacPorts
recipe lints with 0 errors/0 warnings; Homebrew's content loader parses the cask.
Initial MacPorts lint failed on an unquoted semicolon, corrected in generator.
Initial Homebrew path loading rejected a file outside an installed tap; parsing
the trusted local recipe's contents succeeds. Package install tests are pending.

No signing identity is visible in this environment; user is unsure about Apple
Developer membership. Archive is ad-hoc signed, not notarized. Fresh-install
helper approval, mode switching and restart persistence remain unverified.
No global BTM reset, permanent helper installation or current-runtime update
was performed. The user's working old helper PID 79954 remains running.

`scripts/prepare-release.sh --development` builds in `.build/release-staging`
and refuses to overwrite an existing archive. Optional Developer ID/notarytool
preparation uses `--notarized` with signing identity/keychain profile env vars.
`scripts/write-release-recipes.py` generates checksum-pinned Homebrew and local
MacPorts recipes. There is no source license grant; MacPorts uses Restrictive.

`scripts/publish-release.sh` expects branch `release/v0.2.0`, checks
the archive hash, stages an explicit source allowlist and commits the release
using GitHub noreply metadata, pushes only that branch, publishes GitHub v0.2.0 as a
prerelease, and creates a separate public `homebrew-inside-battery` tap with
the release branch as its default. No push to main, official registry submission,
Gatekeeper bypass, or silent administrator approval occurs. Initial restricted
Codex execution blocked `.git/index.lock` writes and GitHub networking. User
changed to Full access; authentication and publication then succeeded.
Release source commit: `b0dffee`, pushed on `release/v0.2.0` only.
Public prerelease: https://github.com/JonathanLee2020/inside-battery/releases/tag/v0.2.0
Public tap: https://github.com/JonathanLee2020/homebrew-inside-battery
Tap commit: `79d8ce8`; default branch `release/v0.2.0`.
Public ZIP downloaded without authentication: 204162 bytes, SHA-256 matches above.
Install command: `brew install --cask JonathanLee2020/inside-battery/inside-battery`.
MacPorts lint reports 0 errors/0 warnings; Homebrew content-loader
parsing passes without a recipe deprecation warning. No package installation
test has run. Original app still uses the working temporary helper.

## Current runtime rollback

NEUTRAL ENERGY MODE HOVER INSTALLED: user reversed colored hover request after
providing native battery reference. EnergyModeRow uses macOS semantic neutral
unemphasizedSelectedContentBackgroundColor and normal labelColor text; explicit
mode constructor removed. Selected icon circles remain blue/yellow/purple.
This matches the neutral native style; no claim of using Apple's private battery
control. All three row renders inspected, build and installed 171 checks pass.
Original helper/client unchanged, signature verified, app reopened after quit.
Backup: `.build/rollback-backups/interface-install.ikwNly/Inside Battery.app`.
No new commit or published release.

ENERGY MODE HOVER COLORS INSTALLED: EnergyModeRow now stores its explicit mode
and draws hover with BatteryMenu.selectionColor(for:), shared with selected icon
circles. Automatic blue, Low Power yellow, High Power lighter purple. Hover title
is black on yellow/purple, native selected text on blue. Rounded highlight shape,
mouse activation and menu tracking unchanged. All three actual row draw methods
rendered and inspected; build and installed 171 checks pass. Original helper/client
unchanged, signatures verified, app reopened after user quit. Backup:
`.build/rollback-backups/interface-install.gY1Uu2/Inside Battery.app`.
No new commit or published release.

ENERGY MODE SELECTION COLORS INSTALLED: selected Automatic circle stays blue,
Low Power uses system yellow, High Power shares BatteryIcon.highPowerColor
(lighter purple) with the menu-bar fill. Low/High use black inner symbols and
65%-black thin outlines for contrast; Automatic retains white interior and pale
outline. Unselected circles unchanged. Render inspected, build and 171 checks
pass; selected-circle pixel checks now verify each mode's hue. Installed main
only after user quit, signatures verified, original helper/client unchanged,
reopened successfully. Backup:
`.build/rollback-backups/interface-install.Kdqb26/Inside Battery.app`.
No new commit or published release.

SELECTED OUTLINE CONTRAST CORRECTION INSTALLED: shared grey outline was too dark
against blue selection. Native screenshot shows a pale outline. Selected border
and terminal now use pale blue-grey RGB 0.80/0.88/0.94, preserving 1 pt thickness,
blue circle and white interior; unselected stays grey. Render inspected, build
and installed 171 checks pass; original helper/client byte-identical, app reopened.
Backup: `.build/rollback-backups/interface-install.yAaV6X/Inside Battery.app`.
No new commit or published release.

MATCHING ENERGY MODE OUTLINES INSTALLED: selected icon appeared thicker due to
white outline; both states already used 1 pt strokes. Selected now uses the same
grey outline/terminal RGB 0.60/0.60/0.62 as unselected, retaining blue circle and
white interior symbol. Before/after render inspected, build and 171 checks pass.
Installed main only after user quit, signatures verified, original helper/client
unchanged, reopened successfully. Backup:
`.build/rollback-backups/interface-install.O5aehk/Inside Battery.app`.
No new commit or published release.

ENERGY LIST PARSER FIX INSTALLED: live `--print-energy-apps` reproduced
"The native energy response contains an invalid app identity." A raw query
returned WindowServer with empty responsible ID and display name. Parser now
filters unnamed coalitions before app identity validation, without a process-name
special case. Named invalid identities and malformed response arrays still fail.
Regression fixtures cover system-only, mixed named/unnamed, and invalid named
records. Build and 171 checks pass. Both staged and installed executable return
"No apps using significant energy" against current live macOS data, exit 0.
Installed main only after user quit; original client/helper unchanged, signature
verified, app reopened successfully. Backup:
`.build/rollback-backups/interface-install.5fsbnB/Inside Battery.app`.
No new commit or published release; v0.2.0 download predates this fix.

HIGH POWER PROGRESS VISIBILITY INSTALLED: user reported High Power appearing
full despite partial charge. Rendered before/after fixtures at 25/50/73/95/100%
reproduced near-identical purple fill and remainder. High Power now uses lighter
purple fill RGB 0.86/0.69/0.98 against grey remainder 0.62/0.62/0.66, including
while charging; purple outline lightened. Fill/remainder luminance contrast is
1.465:1. Menu-bar chevrons removed; Energy Mode row symbols unchanged.
Initial self-check failed the old dark-purple color expectation; color checks
updated to require visibly violet light fill, contrasting remainder, and purple
while charging. Build and 168 checks pass. Installed main executable only after
user quit; signature verified and original helper/client compared byte-for-byte.
Backup: `.build/rollback-backups/interface-install.ds3Zj2/Inside Battery.app`.
Reopening now succeeds with Full access. No new commit or download release.

STATUS WIDTH CORRECTION INSTALLED: user screenshot showed oversized highlighted
area after the fixed 49 pt status-item change. Restored NSStatusItem.variableLength
and removed the unused accessory slot when unplugged: icon canvas is 30 pt on
battery/unavailable, 35 pt on external power. Closer accessory positions remain.
168 checks and signatures pass, original helper/client unchanged. Actual native
status button/pill width awaits desktop confirmation (do not claim measured total).
Backup: `.build/rollback-backups/interface-install.u19QZp/Inside Battery.app`.
Automatic reopening again failed; user must reopen as before.

COMPACT MENU-BAR ICON INSTALLED: lightning/plug moved 1 pt toward the battery,
terminal narrowed slightly to retain a small gap; High Power terminal chevrons
also compressed to avoid the accessory. Icon canvas narrowed 36 to 35 pt.
Status item now has an explicit 49 pt width (35 pt image + 14 pt total padding).
Rendered icons inspected, 168 checks and signatures pass. Original helper/client
unchanged; backup `.build/rollback-backups/interface-install.RMJaom/Inside Battery.app`.
Automatic reopening failed in the agent; desktop spacing awaits user confirmation.

MODE BRIGHTNESS UPDATE INSTALLED: mode rows no longer become disabled solely
because `changingMode` is true, preventing their custom view's 40% opacity /
disabled text flash during a switch. The action guard still blocks overlapping
requests; genuinely unavailable modes remain disabled. User confirmed previous
custom rows keep the menu open, but reported the dimming. 168 checks and
signatures pass; original helper/client unchanged. Backup:
`.build/rollback-backups/interface-install.OyOoTS/Inside Battery.app`.
Reopen failed in the agent; visual no-dimming check remains pending desktop use.

PERSISTENT ENERGY MODE MENU INSTALLED: `EnergyModeRow.swift` provides custom
mouse-driven menu views for the three mode rows, sends their existing actions
without standard command selection/dismissal, and draws hover/disabled/selected
states with accessibility press support. AppDelegate refreshes mode icons in
place and disables mode clicks during a change. Completion is dispatched into
default and event-tracking run-loop modes so it can update/re-enable controls
while the menu remains open. Errors close tracking to present their alert.
Staged in `.build/interface-updates/persistent-modes-2026-10-08/Inside Battery.app`.
168 existing checks and signature checks pass. Actual keep-open clicks remain
unverified through desktop automation; user must confirm after installation.
Installed after user quit; installer preserved the working original pair.
Backup: `.build/rollback-backups/interface-install.4ci5tp/Inside Battery.app`.
Automatic reopen failed in the agent; user must reopen and test switching
between modes without dismissing the menu. Standard keyboard menu activation
still uses NSMenu behaviour; keep-open custom activation covers mouse/AX press.

UNPLUGGED PADDING UPDATE INSTALLED: header bottom padding is now uniformly 2 pt;
on-battery padding reduced from 8 to 2 pt, closing the gap between Power Source:
Battery and the divider by 6 pt. Connected padding is retained at 2 pt. 168
self-checks and signatures pass; original helper/client unchanged. Backup:
`.build/rollback-backups/interface-install.2GoRuh/Inside Battery.app`.
Automatic reopen failed in the agent; user must reopen to confirm appearance.

SLIMMER BATTERY SHAPES INSTALLED: menu-bar battery body reduced from 25x16 to
25x14 pt, centred vertically, with a proportional terminal and corner radius.
Energy Mode battery bodies reduced from 17x10 to 17x8 pt, with shorter fills,
terminals and centred High Power arrows. Icon widths/circle sizes remain the
same. A rendered preview of all modes and percentage icons was inspected;
168 self-checks and signatures pass. Original helper/client unchanged.
Backup: `.build/rollback-backups/interface-install.CcVzW9/Inside Battery.app`.
Automatic reopening failed in the agent; user must reopen and check appearance.

GREY ROW SPACING UPDATE INSTALLED: detail row pitch/field height reduced from
20 to 17 pt for source, charging estimate and charger capacity; header shrinks
accordingly, retaining title spacing and bottom padding. 168 self-checks and
installed bundle signature pass, original helper/client unchanged. Backup:
`.build/rollback-backups/interface-install.cFFaBp/Inside Battery.app`.
Automatic reopening failed in the agent; desktop appearance awaits user reopen.

HEADER TEXT UPDATE INSTALLED: regular header rows (power source/status, charge
estimate, charger capacity) changed from 13 pt labelColor to 12 pt
secondaryLabelColor to follow the native screenshot's smaller grey text.
Battery title and percentage retain 13 pt semibold labelColor. 168 checks and
signatures pass; live desktop appearance awaits user confirmation. Original
client/helper remain unchanged. Backup:
`.build/rollback-backups/interface-install.GUVWxF/Inside Battery.app`.
Automatic reopening failed again in the agent; user must open the app manually.

HEADER SPACING UPDATE INSTALLED: connected-power header bottom padding reduced
from 8 to 2 pt, shrinking the gap below charger capacity by 6 pt. Other row
spacing and on-battery padding remain the same. Staged in
`.build/interface-updates/header-spacing-2026-10-08/Inside Battery.app`, passing
168 checks and signatures. Installer points to this bundle and preserves the
original helper/client. Installed after user quit. Backup:
`.build/rollback-backups/interface-install.fjlG9x/Inside Battery.app`.
Automatic reopening failed with kLSNoExecutableErr; user must reopen the app.
Desktop appearance confirmation remains pending.

CHARGE ESTIMATE INSTALLED: `Inside Battery` submenu now includes a persistent
`Show Time Until Fully Charged` toggle (default on, UserDefaults key
`showTimeUntilFull`). While charging below 100%, header adds a time estimate
row using public IOKit `kIOPSTimeToFullChargeKey` (minutes). Hours/minutes and
singular/plural are formatted; -1 shows calculating, missing/invalid estimates
show unavailable, and paused/unplugged/full/absent batteries hide the row.
State copies retain valid estimates. Combined Power Adapter/status row remains.
Staged at `.build/interface-updates/charge-estimate-2026-10-08/Inside Battery.app`.
168 checks and signature checks pass. Live read: 89%, charging on AC, estimate
36 minutes until full. GUI/toggle behaviour requires desktop confirmation.
Installed after user quit GUI. Backup at
`.build/rollback-backups/interface-install.yzplyi/Inside Battery.app`.
Installer preserved original helper/client. Automatic reopening failed with
kLSNoExecutableErr in the agent; user must reopen the real app as before.

LATEST UI INSTALLED: unselected Energy Mode icons now have a grey outline and
terminal with a white fill in dark appearance; selected icons retain white on
blue, matching the native selected reference. Header source and charge status
now share one row, e.g. `Power Source: Power Adapter · Charging`; separate status
row removed and header height reduced by 20 pt. Charging, Not Charging, and
Fully Charged source lines were measured and fit within the 282 pt label width.
153 self-checks pass, a rendered grey-outline preview was visually inspected,
and the original helper/client remain byte-identical. Backup:
`.build/rollback-backups/interface-install.PvmF3a/Inside Battery.app`.
Automatic reopening again failed in the agent; user must reopen the real app.

COSMETIC UPDATE INSTALLED after user quit and clarified that only Energy Mode
menu icon borders should be thinned. Menu battery outlines are now 1 pt,
High Power arrows are horizontally centred, and violet colors are lighter.
Menu-bar border thickness was restored to its previous 1.5 pt in High Power /
0.75 pt otherwise before installation. Main executable alone was replaced;
original helper/client are unchanged. 153 checks and signatures pass.
Backup: `.build/rollback-backups/interface-install.jez0ZC/Inside Battery.app`.
Automatic reopen from the agent again failed with kLSNoExecutableErr; user
must open the app as before. Desktop appearance confirmation remains pending.

Pending cosmetic update after user confirmed the updated interface works:
status battery border reduced from High Power 1.5 pt to uniform 0.75 pt;
menu battery outline reduced from 1.25 pt to 1 pt; three High Power arrows
are centred as a group using the battery body's midpoint (previous group
was 1 pt left of centre); violet surface/fill/outline lightened.
Staged at `.build/interface-updates/style-2026-10-08/Inside Battery.app`.
153 checks and signatures pass. A rendered icon preview was inspected at
`/private/tmp/inside-battery-style-preview.png`. Installer now points to this
staging bundle and preserves the original client/helper. User has been asked
to quit the GUI; installation has not happened yet (GUI PID 80633 still active).

UI UPDATE INSTALLED at 10:24 after user quit the GUI and launchctl confirmed its
application service absent. Replaced only `Contents/MacOS/InsideBattery` with the
prepared current-source interface and re-signed the outer app. Original helper
and client remain byte-identical; live helper PID 79954 is still running.
Installed executable passes 153 self-checks and bundle signature verification.
This runtime is now current UI + original helper/client, not the exact original
main binary described in earlier chronological notes below. The source hides
setup when enabled and contains no Disable Quick Power Switching action.
Backup: `.build/rollback-backups/interface-install.dxt4SP/Inside Battery.app`.
Codex `open` failed with kLSNoExecutableErr even though the executable exists
and self-tests run. User must open the real app from regular Terminal/Finder;
menu visibility and switching with this updated interface await desktop checks.
`scripts/install-interface-update.sh` now uses launchctl instead of pgrep to
check for the running GUI (pgrep cannot list processes in the agent sandbox).

Pending UI-only update: user requested removal of Disable Quick Power Switching
after enablement. Current source already hides setup when enabled and has no
disable action. An updated main executable was built and staged in
`.build/interface-updates/2026-10-08/Inside Battery.app`, passing 153 checks and
bundle/client/helper signature checks. Its original client/helper are byte-for-byte
identical to the working runtime pair. Backup of the working app:
`.build/rollback-backups/menu-update.IF5AoW/Inside Battery.app`.
Termination of GUI PID 79606 failed with operation not permitted; user was asked
to quit the GUI. No runtime app files have been replaced. After user quits,
replace ONLY Contents/MacOS/InsideBattery from staging, re-sign the outer app,
verify unchanged original helper/client and live PID 79954, then reopen the app.
Do not run the full build-app.sh: that would rebuild the helper pair.

VERIFIED RECOVERY at 10:20: the user ran the temporary absolute-path diagnostic
and confirmed that power switching worked in the restored original app.
launchd spawned PID 79954 from
`/private/tmp/inside-battery-launch-test.76MBJD/com.insidebattery.power-helper.plist`.
The signed original helper and its client can therefore successfully perform a
live mode change when launchd uses the absolute executable path. The failing
SMAppService BundleProgram resolution remains unrepaired; this temporary load
does not survive a restart. Preserve the working original app/client/helper
pair. Do not rebuild in place or describe the permanent registration as fixed.

At 10:17, the user's fresh administrator logs again show launchd failing to
resolve/execute `Contents/Helpers/InsideBatteryPowerHelper`, before the helper
handles any request. The original app/client/helper signature checks pass.
`scripts/test-original-helper-launch.sh` prepares a temporary root-owned
launchd plist with `Program` set to the original helper's absolute path. It
unloads only the existing Inside Battery service, then bootstraps that temporary
definition. This is a diagnostic, not a permanent SMAppService repair; no app
files or preferences change. Shell syntax and prepare-only/plist validation
passed. Live execution requires the user's regular Terminal and remains pending.
Do not claim a successful helper launch or mode switch from preparation alone.

Follow-up at 10:13: the user's administrator `sfltool dumpbtm` output points to
the correct `dist/Inside Battery.app` and lists the daemon as enabled/allowed,
with UUID `490F33D0-1C5B-4723-8E81-836BE847BD6D`. The live launchctl service still
references BTM UUID `C2B7F40D-7294-444D-ADF1-E07F5C2BC608`, has attempted 68
launches, and reports exit 78 / spawn failed. This establishes a mismatch
between the dumped background-item record and the live submitted service;
it does not yet establish why it occurred. A restart is proposed to check
whether macOS reconstructs the live service from the current record. No
additional source/bundle changes were made; switching remains unverified.

At the user's request, the actual pre-review app bundle was restored from
`.build/retired-builds/2026-10-08/main-before-versioning.app` to
`dist/Inside Battery.app`. The previously running main process was terminated
before replacement; its launchd application service was confirmed absent. The
restored executable passes 142 self-checks and the helper/bundle signature checks.
The replaced bundle is preserved at
`.build/rollback-backups/2026-10-08-before-original-restore.app`.

This is a binary rollback, not a Git/source rollback: the current source retains
the newer menu, charger-capacity work, and helper-registration experiments below.
Those newer UI/features are not present in the restored executable. Rebuilding
will replace this restored executable with the newer source implementation;
do not claim that rebuilding reproduces the original bundle. No source edits,
version tags, or remote commits were discarded or rewritten.

The live registration was still failing with exit 78 even after the user's
outside-Codex repair printed Enabled. The restored app's original enable/disable
and macOS approval flow is available for registering its original helper. A live
mode change after restoration remains unverified. The agent sandbox's service
lookup denial is separate from the desktop helper's launch failure.
Review-build support has been removed. Earlier generated variants and the prior
handoff are archived locally under `.build/retired-builds/` and excluded from Git.

## Start here

1. Read `README.md` and `CHANGELOG.md`.
2. Build the real app with `make app`; run it with `make run`.
3. Verify desktop helper approval and switching before claiming a stable release.

## Implemented

- Native Swift/AppKit accessory app for macOS 13+, with percentage inside a
  36 × 18-point battery icon. Grey on battery, green on external power, yellow
  for Low Power, medium violet accents for High Power. Bolt and plug distinguish
  charging from plugged-in but not charging. Missing data shows a dash.
- Public IOKit notification-driven battery readings, including updates while the
  menu tracks. Low Power notifications refresh the icon. Saved High Power state
  comes from `pmset`; it is refreshed on battery/power events and menu opening.
- Native-style menu: Battery/percentage, source and charge status, Energy Mode,
  significant-energy apps, Battery Settings, app preferences, and top-level Quit.
  Selected modes use a blue circle and white battery. Empty energy results and
  query errors each use one status line; unavailable data is not reported as empty.
- Optional `SMAppService` root helper. A short-lived native XPC client and helper
  pin each other's signature hashes. Only the active console user is accepted,
  with closed mode/profile enums and saved-preference verification. No arbitrary
  shell requests or stored passwords. Setup hides after approval; connection
  failures expose a repair action. There is no standalone disable menu option.
- Launch at login through `SMAppService.mainApp`.

## File map

| Files | Responsibility |
| --- | --- |
| `Sources/InsideBattery/AppDelegate.swift`, `BatteryMenu.swift`, `main.swift` | App/menu, registration, diagnostics |
| `BatteryState.swift`, `BatteryMonitor.swift`, `BatteryIcon.swift` | State, notification subscriptions, icon rendering |
| `PowerMode.swift`, `PowerHelperProtocol.swift`, `Sources/PowerClient/`, `Sources/PowerHelper/` | Preferences, commands, signed XPC |
| `NativeEnergy.swift`, `SelfTest.swift`, `Tests/InsideBatteryTests/` | Experimental energy integration and checks |
| `scripts/`, `Resources/`, `Package.swift`, `Makefile`, `packaging/` | Build, bundle, diagnostics, future packaging template |

## Important limits

Latest helper investigation: desktop logs confirmed launchd's repeating
`Could not find and/or execute program ... Contents/Helpers/InsideBatteryPowerHelper`
and exit 78 (EX_CONFIG), even though the bundled executable exists. The earlier
repair used synchronous unregister followed immediately by register. Apple's
SDK documents that this call returns before the process is reaped and only the
asynchronous completion establishes when re-registration is safe. Repair now
awaits that completion. This corrects the confirmed lifecycle violation; the
live stale-registration repair remains pending desktop verification.

Added `--repair-power-helper`, `--check-power-helper`, and `--print-helper-status`.
The helper protocol's connection check is authenticated with the same pinned
signature requirements and changes no settings. UI/Terminal setup checks its
response before reporting success. Pending macOS approval is reported separately.
Registration errors and helper-side mode errors remain visible. Terminal repair
must run outside the agent sandbox, which denies mach lookup to this service.

1. Native energy data uses a private `systemstats_get_top_coalitions` ABI, guarded
   to macOS 26.2. Queries occur on menu opening, normally over 120 seconds with
   five results and a minimum score of 60,000. A ten-second UI timeout does not
   terminate the native call. The development query returned nil; live app rows
   and Activity Monitor selection remain unverified. Scores are not watts.
2. Ad-hoc development signatures change on rebuild. The registered service must
   match the running build's client/helper. Earlier main/review copies shared
   the service identity but had different hashes, causing connection failures.
   The review workflow has been retired; use only the real app. Registration,
   system approval, and successful switching after a rebuild still need desktop
   verification. Do not equate registration with macOS approval.
3. A client SIGTRAP in an XPC error callback was reproduced and diagnosed from
   crash reports. Callbacks now originate in a nonisolated function. Connection
   failures produce readable errors instead of inheriting the main actor.
4. The connected-power menu header now shows **Charger capacity: … W** from the
   public `IOPSCopyExternalPowerAdapterDetails` API. Missing ratings display
   Unavailable, and unplugging clears the rating. No live input-power measurement
   is implemented. The `system_profiler` Wattage field describes adapter capability. Current
   telemetry did not expose `PowerTelemetryData.SystemPowerIn` even when connected.
   Battery voltage × current describes battery power, not total adapter input.
5. Public app downloads are deferred. Developer ID signing and notarization are
   required before binary distribution; the Homebrew cask is only a template.

## Verification on 8 October 2026

The real app builds with the installed macOS 15.4 SDK and a workspace module cache:

```sh
CLANG_MODULE_CACHE_PATH="$PWD/.build/module-cache" \
SWIFTPM_MODULECACHE_OVERRIDE="$PWD/.build/module-cache" \
SWIFT_SDK=/Library/Developer/CommandLineTools/SDKs/MacOSX15.4.sdk \
DISABLE_SWIFTPM_SANDBOX=1 sh scripts/build-app.sh
```

```text
PASS: 153 Inside Battery self-checks
PASS: helper's embedded requirement accepts the bundled client
PASS: helper's embedded requirement rejects a different executable
PASS: client's pinned helper hash matches the bundled helper
PASS: complete bundle signature verifies
```

The signature script intentionally emits a rejection diagnostic for the wrong
executable. Checks include state parsing, notifications, power preferences and
commands, native-energy fixtures/event structure, icon rendering and contrast,
and selected-mode icon pixels. Icon previews were visually inspected.
The charger-capacity fixtures verify a 96 W reading, preservation across mode
updates, clearing on unplug, and missing/zero handling. A test that instantiated
the header crashed with exit 134 in AppKit application registration because the
headless environment cannot register a GUI process; that UI-only check was
removed, retaining the data-path checks. The rebuilt self-checks then passed.
The live adapter reading returned unavailable, and System Information exposed
no Wattage value during this verification. A real rated value and the new header
still require desktop verification with a charger whose rating macOS reports.

Default `make test` failed before tests: sandbox cache permissions and a reported
SDK/compiler mismatch. A source build succeeded with the above configuration,
but `swift test` failed with `no such module 'XCTest'`; the installed Command Line
Tools lack that framework. No XCTest pass is claimed. Live helper repair, approval,
mode switching with the latest helper, and the revised desktop menu remain
unverified. Computer-use inspection timed out. Attempting to terminate the last
running review copy on retirement returned `operation not permitted`.

## Source versioning

The initial development snapshot is version 0.1.0. Version tags preserve source
history; no GitHub downloadable releases or app binaries are published. Build
artifacts and local environment files are ignored. Use tagged worktrees to inspect
old versions, restore branches to build on them, or revert commits to undo changes
without rewriting shared history. See `README.md` for commands.

Git has been initialized on `initial-import` and the source staged. Commit failed
with `Unable to create '.git/index.lock': Operation not permitted`; no commit or
version tag exists yet. Restaging the final documentation/script also failed with
the same lock permission error. GitHub CLI authentication/network access failed in the
agent sandbox, and escalation is disabled. Run `sh scripts/publish-source.sh`
from the user's Terminal to authenticate, create the initial commit/tag, create
the public `inside-battery` repo, and push the branch/tag. Publication is not yet
verified. The script uses GitHub noreply metadata, excludes generated apps, does
not push to main, and does not create binary releases.
