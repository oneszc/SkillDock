#!/bin/zsh
set -euo pipefail

APP_DIR="${1:-dist/SkillDock.app}"
EXECUTABLE="$APP_DIR/Contents/MacOS/SkillDock"
PLIST="$APP_DIR/Contents/Info.plist"
ICON="$APP_DIR/Contents/Resources/SkillDock.icns"
APPEARANCE_RESOURCES="$APP_DIR/Contents/Resources/SkillDock_SkillDockApp.bundle"

test -d "$APP_DIR"
test -x "$EXECUTABLE"
test -f "$ICON"
test -f "$APPEARANCE_RESOURCES/System.png"
test -f "$APPEARANCE_RESOURCES/Light.png"
test -f "$APPEARANCE_RESOURCES/Dark.png"
plutil -lint "$PLIST"
codesign --verify --deep --strict --verbose=2 "$APP_DIR"
test "$(/usr/libexec/PlistBuddy -c 'Print :CFBundlePackageType' "$PLIST")" = "APPL"
test "$(/usr/libexec/PlistBuddy -c 'Print :CFBundleIconFile' "$PLIST")" = "SkillDock.icns"
test "$(/usr/libexec/PlistBuddy -c 'Print :LSMinimumSystemVersion' "$PLIST")" = "26.0"

echo "Verified $APP_DIR"
