# Local MacPorts recipe

`aqua/inside-battery/Portfile` is a checksum-pinned Apple Silicon binary-preview
recipe. It is **not in the official MacPorts ports tree**. It downloads the same
v0.2.0 ZIP after the GitHub release exists and stages the app under MacPorts'
configured applications directory, normally `/Applications/MacPorts`.

Read-only recipe validation:

```sh
port -D packaging/macports/aqua/inside-battery lint
```

After publication, test installation on a separate Mac or account:

```sh
sudo port -D packaging/macports/aqua/inside-battery install
```

Fresh-install helper approval, updates, uninstall handling and restart persistence
must be tested before submitting this port. The app is not notarized, and no
Gatekeeper bypass is included. The current source has no license grant; the
recipe records `Restrictive` rather than inventing an open-source license.

MacPorts' normal port review is a separate step from hosting a GitHub download.
