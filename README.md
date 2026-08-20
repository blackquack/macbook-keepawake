# macbook-keepawake

macbook-keepawake is a small macOS menu-bar utility that keeps a Mac awake when its lid is closed while allowing the display to sleep normally.

While enabled, the app creates a user-level IOKit power assertion using `kIOPMAssertionTypePreventSystemSleep`. The toggle is available only while AC power is connected. Unplugging disables the assertion. No privileged helper, LaunchDaemon, or administrator approval is required.

macOS can still sleep during a thermal emergency. Do not put a closed, running Mac in a bag or enclosed space.

## Build

This project uses Swift Package Manager and the macOS Command Line Tools. Full Xcode is not required.

```bash
./Scripts/build-app.sh
./Scripts/package-zip.sh
```

The app and ZIP output are in `dist/`.

## Test

```bash
swift run --disable-sandbox --cache-path work/swiftpm-cache --manifest-cache local LidKeepAwakeTests
./Scripts/e2e.sh
```

The E2E script validates the app bundle and signing. Test enabling on AC and confirm the toggle is disabled on battery. Use `pmset -g assertions` to inspect the active power assertion.
