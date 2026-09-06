#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SCHEME="Aurelius"
BUNDLE_ID="robzcode.Aurelius"
DERIVED_DATA="$ROOT/build"
APP_PATH="$DERIVED_DATA/Build/Products/Debug-iphonesimulator/Aurelius.app"
SIMULATOR_NAME="${SIMULATOR_NAME:-iPhone 16e}"

cd "$ROOT"

echo "→ Opening Simulator..."
open -a Simulator

echo "→ Building for iOS Simulator ($SIMULATOR_NAME)..."
xcodebuild \
  -scheme "$SCHEME" \
  -destination "platform=iOS Simulator,name=$SIMULATOR_NAME" \
  -derivedDataPath "$DERIVED_DATA" \
  build

echo "→ Installing app..."
xcrun simctl install booted "$APP_PATH"

echo "→ Launching $BUNDLE_ID..."
xcrun simctl launch booted "$BUNDLE_ID"
