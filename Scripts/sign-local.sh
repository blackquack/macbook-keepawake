#!/bin/bash
set -euo pipefail

APP_DIR="${1:?Usage: sign-local.sh /path/to/macbook-keepawake.app}"
ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"

/usr/bin/codesign --force --sign - --timestamp=none \
  --entitlements "$ROOT_DIR/Resources/Entitlements/App.entitlements" \
  "$APP_DIR"

/usr/bin/codesign --verify --deep --strict "$APP_DIR"
