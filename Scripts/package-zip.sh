#!/bin/bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
APP_DIR="$ROOT_DIR/dist/macbook-keepawake.app"
ZIP_PATH="$ROOT_DIR/dist/macbook-keepawake.zip"

if [[ ! -d "$APP_DIR" ]]; then
  "$ROOT_DIR/Scripts/build-app.sh"
fi

rm -f "$ZIP_PATH"
/usr/bin/ditto -c -k --keepParent "$APP_DIR" "$ZIP_PATH"
echo "Packaged $ZIP_PATH"
