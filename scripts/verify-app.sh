#!/bin/zsh
set -euo pipefail

APP_DIR="${1:-dist/SkillDock.app}"
EXECUTABLE="$APP_DIR/Contents/MacOS/SkillDock"
PLIST="$APP_DIR/Contents/Info.plist"
ICON="$APP_DIR/Contents/Resources/SkillDock.icns"
APPEARANCE_RESOURCES="$APP_DIR/Contents/Resources/SkillDock_SkillDockApp.bundle"
if [[ -d "$APPEARANCE_RESOURCES/Contents/Resources" ]]; then
    APP_BUNDLE_RESOURCES="$APPEARANCE_RESOURCES/Contents/Resources"
else
    APP_BUNDLE_RESOURCES="$APPEARANCE_RESOURCES"
fi

test -d "$APP_DIR"
test -x "$EXECUTABLE"
test -f "$ICON"
test -f "$APP_BUNDLE_RESOURCES/System.png"
test -f "$APP_BUNDLE_RESOURCES/Light.png"
test -f "$APP_BUNDLE_RESOURCES/Dark.png"
test -f "$APP_BUNDLE_RESOURCES/codex.svg"
test -f "$APP_BUNDLE_RESOURCES/claude.svg"
test -f "$APP_BUNDLE_RESOURCES/codex-gray.svg"
test -f "$APP_BUNDLE_RESOURCES/claude-gray.svg"
plutil -lint "$PLIST"
codesign --verify --deep --strict --verbose=2 "$APP_DIR"
test "$(/usr/libexec/PlistBuddy -c 'Print :CFBundlePackageType' "$PLIST")" = "APPL"
test "$(/usr/libexec/PlistBuddy -c 'Print :CFBundleIconFile' "$PLIST")" = "SkillDock.icns"
test "$(/usr/libexec/PlistBuddy -c 'Print :LSMinimumSystemVersion' "$PLIST")" = "26.0"

echo "Verified $APP_DIR"
