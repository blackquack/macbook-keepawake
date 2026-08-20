#!/bin/bash
set -euo pipefail

APP_DIR="${1:?Usage: sign-local.sh /path/to/LidKeepAwake.app}"
ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
HELPER="$APP_DIR/Contents/Library/HelperTools/LidKeepAwakeHelper"

/usr/bin/codesign --force --sign - --timestamp=none \
  --entitlements "$ROOT_DIR/Resources/Entitlements/Helper.entitlements" \
  "$HELPER"

/usr/bin/codesign --force --sign - --timestamp=none \
  --entitlements "$ROOT_DIR/Resources/Entitlements/App.entitlements" \
  "$APP_DIR"

/usr/bin/codesign --verify --deep --strict "$APP_DIR"
