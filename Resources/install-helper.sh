#!/bin/sh
set -eu

HELPER_SOURCE="$1"
PLIST_SOURCE="$2"
HELPER_DEST="/Library/PrivilegedHelperTools/com.local.lidkeepawake.helper"
PLIST_DEST="/Library/LaunchDaemons/com.local.lidkeepawake.helper.plist"
LABEL="com.local.lidkeepawake.helper"

/bin/mkdir -p "/Library/PrivilegedHelperTools"
/usr/bin/install -o root -g wheel -m 755 "$HELPER_SOURCE" "$HELPER_DEST"
/usr/bin/install -o root -g wheel -m 644 "$PLIST_SOURCE" "$PLIST_DEST"

/bin/launchctl bootout "system/$LABEL" >/dev/null 2>&1 || true
/bin/launchctl bootstrap system "$PLIST_DEST"
