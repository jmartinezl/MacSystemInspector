#!/bin/bash
# Compila la app en Release con firma ad-hoc y genera build/MacSystemInspector-<versión>.dmg.
# Uso: scripts/build-dmg.sh [versión]
set -euo pipefail

cd "$(dirname "$0")/.."

APP_NAME="MacSystemInspector"
VERSION="${1:-dev}"
DERIVED="build/DerivedData"
STAGING="build/dmg"
DMG="build/${APP_NAME}-${VERSION}.dmg"

BUILD_ARGS=(
  CODE_SIGN_STYLE=Manual
  CODE_SIGN_IDENTITY=-
  DEVELOPMENT_TEAM=
  CODE_SIGN_INJECT_BASE_ENTITLEMENTS=NO
)
if [[ "$VERSION" != "dev" ]]; then
  BUILD_ARGS+=(MARKETING_VERSION="$VERSION")
fi

xcodebuild -project "${APP_NAME}.xcodeproj" -scheme "$APP_NAME" \
  -destination 'generic/platform=macOS' -configuration Release \
  -derivedDataPath "$DERIVED" "${BUILD_ARGS[@]}" build

APP="${DERIVED}/Build/Products/Release/${APP_NAME}.app"
codesign --verify --deep --strict "$APP"

rm -rf "$STAGING" "$DMG"
mkdir -p "$STAGING"
cp -R "$APP" "$STAGING/"
ln -s /Applications "$STAGING/Applications"

hdiutil create -volname "$APP_NAME" -srcfolder "$STAGING" -fs HFS+ -format UDZO "$DMG"
rm -rf "$STAGING"

echo "DMG generado: $DMG"
