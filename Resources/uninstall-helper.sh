#!/bin/sh
set -eu

LABEL="com.local.lidkeepawake.helper"

/bin/launchctl bootout "system/$LABEL" >/dev/null 2>&1 || true
/bin/rm -f "/Library/PrivilegedHelperTools/com.local.lidkeepawake.helper"
/bin/rm -f "/Library/LaunchDaemons/com.local.lidkeepawake.helper.plist"
