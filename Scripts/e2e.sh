#!/bin/bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
APP_DIR="$ROOT_DIR/dist/macbook-keepawake.app"

mkdir -p "$ROOT_DIR/work/clang-module-cache" "$ROOT_DIR/work/swift-module-cache"
env \
  CLANG_MODULE_CACHE_PATH="$ROOT_DIR/work/clang-module-cache" \
  SWIFT_MODULE_CACHE_PATH="$ROOT_DIR/work/swift-module-cache" \
  swift run --disable-sandbox --cache-path "$ROOT_DIR/work/swiftpm-cache" --manifest-cache local LidKeepAwakeTests
"$ROOT_DIR/Scripts/build-app.sh"
"$ROOT_DIR/Scripts/package-zip.sh"

/usr/bin/plutil -lint "$APP_DIR/Contents/Info.plist"
/usr/bin/codesign --verify --deep --strict "$APP_DIR"

echo
echo "Bundle checks passed. Physical lid testing is manual."
echo "Open with: open '$APP_DIR'"
echo "The toggle uses a user-level IOKit power assertion; no helper installation is required."
echo "Then test AC enablement and battery lockout, and inspect assertions with: pmset -g assertions"
