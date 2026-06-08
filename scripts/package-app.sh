#!/bin/zsh
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
APP_NAME="SkillDock"
BUNDLE_ID="com.oneszc.SkillDock"
VERSION="${SKILLDOCK_VERSION:-0.2.1}"
BUILD_DIR="$ROOT_DIR/.build/release"
DIST_DIR="$ROOT_DIR/dist"
APP_DIR="$DIST_DIR/$APP_NAME.app"
CONTENTS_DIR="$APP_DIR/Contents"
MACOS_DIR="$CONTENTS_DIR/MacOS"
RESOURCES_DIR="$CONTENTS_DIR/Resources"
ICON_FILE="$ROOT_DIR/Resources/SkillDock.icns"
APP_RESOURCE_BUNDLE="$BUILD_DIR/SkillDock_SkillDockApp.bundle"

cd "$ROOT_DIR"
swift build -c release --product SkillDockApp

rm -rf "$APP_DIR"
mkdir -p "$MACOS_DIR" "$RESOURCES_DIR"
cp "$BUILD_DIR/SkillDockApp" "$MACOS_DIR/$APP_NAME"
cp "$ICON_FILE" "$RESOURCES_DIR/SkillDock.icns"
cp -R "$APP_RESOURCE_BUNDLE" "$RESOURCES_DIR/"

cat > "$CONTENTS_DIR/Info.plist" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleDevelopmentRegion</key>
    <string>en</string>
    <key>CFBundleExecutable</key>
    <string>$APP_NAME</string>
    <key>CFBundleIdentifier</key>
    <string>$BUNDLE_ID</string>
    <key>CFBundleInfoDictionaryVersion</key>
    <string>6.0</string>
    <key>CFBundleIconFile</key>
    <string>SkillDock.icns</string>
    <key>CFBundleName</key>
    <string>$APP_NAME</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>$VERSION</string>
    <key>CFBundleVersion</key>
    <string>1</string>
    <key>LSMinimumSystemVersion</key>
    <string>26.0</string>
    <key>NSHighResolutionCapable</key>
    <true/>
</dict>
</plist>
PLIST

codesign --force --options runtime --sign - "$APP_DIR"

rm -f "$DIST_DIR/$APP_NAME-$VERSION.zip"
ditto -c -k --keepParent "$APP_DIR" "$DIST_DIR/$APP_NAME-$VERSION.zip"

"$ROOT_DIR/scripts/verify-app.sh" "$APP_DIR"
echo "Created $APP_DIR"
echo "Created $DIST_DIR/$APP_NAME-$VERSION.zip"
