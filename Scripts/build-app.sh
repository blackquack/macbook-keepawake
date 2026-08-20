#!/bin/bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
DIST_DIR="$ROOT_DIR/dist"
APP_DIR="$DIST_DIR/LidKeepAwake.app"
CONTENTS_DIR="$APP_DIR/Contents"

cd "$ROOT_DIR"
mkdir -p "$ROOT_DIR/work/clang-module-cache" "$ROOT_DIR/work/swift-module-cache"
env \
  CLANG_MODULE_CACHE_PATH="$ROOT_DIR/work/clang-module-cache" \
  SWIFT_MODULE_CACHE_PATH="$ROOT_DIR/work/swift-module-cache" \
  swift build --disable-sandbox --cache-path "$ROOT_DIR/work/swiftpm-cache" --manifest-cache local -c release

rm -rf "$APP_DIR"
mkdir -p \
  "$CONTENTS_DIR/MacOS" \
  "$CONTENTS_DIR/Library/HelperTools" \
  "$CONTENTS_DIR/Library/LaunchDaemons" \
  "$CONTENTS_DIR/Resources"

cp "$ROOT_DIR/Resources/AppInfo.plist" "$CONTENTS_DIR/Info.plist"
cp "$ROOT_DIR/.build/arm64-apple-macosx/release/LidKeepAwake" "$CONTENTS_DIR/MacOS/LidKeepAwake"
cp "$ROOT_DIR/.build/arm64-apple-macosx/release/LidKeepAwakeHelper" "$CONTENTS_DIR/Library/HelperTools/LidKeepAwakeHelper"
cp "$ROOT_DIR/Resources/LaunchDaemons/com.local.lidkeepawake.helper.plist" "$CONTENTS_DIR/Library/LaunchDaemons/com.local.lidkeepawake.helper.plist"
cp "$ROOT_DIR/Resources/install-helper.sh" "$CONTENTS_DIR/Resources/install-helper.sh"
cp "$ROOT_DIR/Resources/uninstall-helper.sh" "$CONTENTS_DIR/Resources/uninstall-helper.sh"
chmod 755 "$CONTENTS_DIR/Resources/install-helper.sh" "$CONTENTS_DIR/Resources/uninstall-helper.sh"

"$ROOT_DIR/Scripts/sign-local.sh" "$APP_DIR"

echo "Built $APP_DIR"
