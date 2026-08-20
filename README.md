# LidKeepAwake

LidKeepAwake is a small macOS menu-bar utility that keeps a Mac awake when its lid is closed.

Version 1 uses one switch for both AC power and battery power. It changes the macOS power-management flag with:

```text
/usr/bin/pmset -a disablesleep 1
/usr/bin/pmset -a disablesleep 0
```

Do not put a closed, running Mac in a bag or enclosed space. The app can keep the Mac running on battery until the battery is empty.

## Build

This project uses Swift Package Manager and the macOS Command Line Tools. Full Xcode is not required.

```bash
./Scripts/build-app.sh
./Scripts/package-zip.sh
```

The output is in `dist/`.

## Install the helper

Open the app and click the toggle. The first enable action installs a narrowly scoped root LaunchDaemon and asks for administrator approval once. The app then communicates with the helper over XPC.

The helper accepts only these operations:

- enable sleep prevention;
- disable sleep prevention;
- report current status;
- ping.

It does not execute arbitrary shell commands.

## Test

```bash
swift run --disable-sandbox --cache-path work/swiftpm-cache --manifest-cache local LidKeepAwakeTests
./Scripts/e2e.sh
```

The E2E script validates the app bundle and signing. Closing the physical lid must be tested manually on AC and battery.
