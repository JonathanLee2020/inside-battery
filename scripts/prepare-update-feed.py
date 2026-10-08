"""Prepare and verify a signed Sparkle feed; never publishes or changes the app."""
import argparse
import html
import pathlib
import plistlib
import subprocess
import xml.etree.ElementTree as ET
import zipfile

parser = argparse.ArgumentParser()
parser.add_argument("archive", nargs="?", type=pathlib.Path)
parser.add_argument("--notes", type=pathlib.Path)
parser.add_argument("--output", required=True, type=pathlib.Path)
parser.add_argument("--tools", type=pathlib.Path, default=pathlib.Path(".build/sparkle-tools/bin"))
args = parser.parse_args()
if args.output.exists():
    parser.error("Output already exists; nothing overwritten. Use a new staging path.")
if args.archive and not args.notes:
    parser.error("An update archive requires --notes.")
sparkle = "http://www.andymatuschak.org/xml-namespaces/sparkle"
custom = "https://github.com/JonathanLee2020/inside-battery/ns"
ET.register_namespace("sparkle", sparkle)
ET.register_namespace("insidebattery", custom)
rss = ET.Element("rss", version="2.0")
channel = ET.SubElement(rss, "channel")
ET.SubElement(channel, "title").text = "Inside Battery Updates"
ET.SubElement(channel, "link").text = "https://github.com/JonathanLee2020/inside-battery/releases"
ET.SubElement(channel, "description").text = "Signed Inside Battery updates"
sign = str(args.tools / "sign_update")
account = "inside-battery"
if args.archive:
    with zipfile.ZipFile(args.archive) as archive:
        prefix = "Inside Battery.app/Contents/"
        info = plistlib.loads(archive.read(prefix + "Info.plist"))
        helper_hash = archive.read(prefix + "Resources/PowerHelperHash.txt").decode().strip()
    key = subprocess.check_output([str(args.tools / "generate_keys"), "--account", account, "-p"], text=True).strip()
    if info.get("SUPublicEDKey") != key:
        raise SystemExit("Archive verification key does not match the signing key in Keychain.")
    if len(helper_hash) != 40 or any(c not in "0123456789abcdefABCDEF" for c in helper_hash):
        raise SystemExit("Archive helper hash is invalid.")
    signature = subprocess.check_output([sign, "--account", account, "-p", str(args.archive)], text=True).strip()
    subprocess.run([sign, "--account", account, "--verify", str(args.archive), signature], check=True)
    item = ET.SubElement(channel, "item")
    version = info["CFBundleShortVersionString"]
    ET.SubElement(item, "title").text = f"Inside Battery {version}"
    ET.SubElement(item, f"{{{sparkle}}}version").text = info["CFBundleVersion"]
    ET.SubElement(item, f"{{{sparkle}}}shortVersionString").text = version
    ET.SubElement(item, f"{{{sparkle}}}minimumSystemVersion").text = info["LSMinimumSystemVersion"]
    ET.SubElement(item, f"{{{custom}}}helperHash").text = helper_hash
    ET.SubElement(item, "description").text = "<pre>" + html.escape(args.notes.read_text()) + "</pre>"
    ET.SubElement(item, "enclosure", {
        "url": f"https://github.com/JonathanLee2020/inside-battery/releases/download/v{version}/{args.archive.name}",
        "length": str(args.archive.stat().st_size), "type": "application/octet-stream",
        f"{{{sparkle}}}edSignature": signature,
    })
args.output.parent.mkdir(parents=True, exist_ok=True)
ET.ElementTree(rss).write(args.output, encoding="utf-8", xml_declaration=True)
subprocess.run([sign, "--account", account, str(args.output)], check=True)
subprocess.run([sign, "--account", account, "--verify", str(args.output)], check=True)
print(f"PASS: signed and verified Sparkle feed: {args.output}")
