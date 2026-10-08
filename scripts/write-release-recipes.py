"""Generate checksum-pinned local package recipes from a real release archive."""
import hashlib
import json
from pathlib import Path
import sys

archive = Path(sys.argv[1]).resolve()
version, kind = sys.argv[2:4]
project = Path(__file__).resolve().parent.parent
digest = hashlib.sha256(archive.read_bytes()).hexdigest()
rmd160 = hashlib.new("ripemd160", archive.read_bytes()).hexdigest()
size = archive.stat().st_size
url = f"https://github.com/JonathanLee2020/inside-battery/releases/download/v{version}/{archive.name}"
manifest = dict(version=version, architecture="arm64", kind=kind,
                archive=archive.name, sha256=digest, size=size)
(archive.parent / "release.json").write_text(json.dumps(manifest, indent=2) + "\n")
(archive.parent / "SHA256SUMS.txt").write_text(f"{digest}  {archive.name}\n")
if kind == "notarized":
    notes = archive.parent / "RELEASE-NOTES.md"
    text = notes.read_text().replace(
        "This development archive is ad-hoc signed, not Developer ID signed or notarized.\n"
        "Gatekeeper may prevent opening a downloaded copy. No quarantine bypass is supplied.",
        "This archive is Developer ID signed, notarized and stapled.\n"
        "Normal Gatekeeper checks remain enabled."
    )
    notes.write_text(text)
cask = f'''cask "inside-battery" do
  version "{version}"
  sha256 "{digest}"

  url "{url}"
  name "Inside Battery"
  desc "Battery percentage inside a native macOS menu-bar icon"
  homepage "https://github.com/JonathanLee2020/inside-battery"

  depends_on arch: :arm64
  depends_on macos: :ventura
  app "Inside Battery.app"

  caveats do
    <<~EOS
      This is a development preview unless the release is marked notarized.
      Power-helper approval and fresh-install switching need verification.
      This cask does not grant administrator approval or bypass Gatekeeper.
    EOS
  end
end
'''
(project / "packaging/homebrew/inside-battery.rb").write_text(cask)
(project / "Casks").mkdir(exist_ok=True)
(project / "Casks/inside-battery.rb").write_text(cask)
port_dir = project / "packaging/macports/aqua/inside-battery"
port_dir.mkdir(parents=True, exist_ok=True)
port = f'''# Local binary preview recipe; not submitted to the official ports tree.
PortSystem          1.0

name                inside-battery
version             {version}
revision            0
categories          aqua sysutils
platforms           {{darwin >= 22}}
supported_archs     arm64
maintainers         nomaintainer
license             Restrictive
description         Native menu-bar battery percentage and energy modes
long_description    "${{description}}. Development preview; helper approval \\
                    and fresh-install switching remain unverified."
homepage            https://github.com/JonathanLee2020/inside-battery
master_sites        https://github.com/JonathanLee2020/inside-battery/releases/download/v{version}
distname            InsideBattery-{version}-arm64
worksrcdir          "Inside Battery.app"
use_zip             yes
checksums           rmd160 {rmd160} \\
                    sha256 {digest} \\
                    size {size}
use_configure       no
build               {{}}
destroot {{
    xinstall -d ${{destroot}}${{applications_dir}}
    copy "${{workpath}}/Inside Battery.app" ${{destroot}}${{applications_dir}}
}}
notes {{Development preview. This port does not grant helper approval or bypass Gatekeeper.}}
'''
(port_dir / "Portfile").write_text(port)
print(f"PASS: archive SHA-256 {digest}; generated Homebrew and local MacPorts recipes")
