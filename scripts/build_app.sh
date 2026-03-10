#!/bin/zsh
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
PROJECT="$ROOT_DIR/NFeDownloadForMAC.xcodeproj"
SCHEME="NFeDownloadForMacApp"
DERIVED_DATA="$ROOT_DIR/.derived-data"
OUTPUT_DIR="$ROOT_DIR/dist"
APP_NAME="NFeDownloadForMacApp.app"

rm -rf "$DERIVED_DATA"
mkdir -p "$OUTPUT_DIR"

xcodebuild \
  -project "$PROJECT" \
  -scheme "$SCHEME" \
  -configuration Release \
  -derivedDataPath "$DERIVED_DATA" \
  -destination 'platform=macOS' \
  build

cp -R "$DERIVED_DATA/Build/Products/Release/$APP_NAME" "$OUTPUT_DIR/$APP_NAME"

echo "App gerado em: $OUTPUT_DIR/$APP_NAME"
