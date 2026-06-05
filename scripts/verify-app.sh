#!/bin/zsh
set -euo pipefail

APP_DIR="${1:-dist/SkillDock.app}"
EXECUTABLE="$APP_DIR/Contents/MacOS/SkillDock"
PLIST="$APP_DIR/Contents/Info.plist"

test -d "$APP_DIR"
test -x "$EXECUTABLE"
plutil -lint "$PLIST"
codesign --verify --deep --strict --verbose=2 "$APP_DIR"
test "$(/usr/libexec/PlistBuddy -c 'Print :CFBundlePackageType' "$PLIST")" = "APPL"
test "$(/usr/libexec/PlistBuddy -c 'Print :LSMinimumSystemVersion' "$PLIST")" = "26.0"

echo "Verified $APP_DIR"
