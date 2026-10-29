#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SCHEME="Aurelius"
DERIVED_DATA="$ROOT/build"
APP_PATH="$DERIVED_DATA/Build/Products/Debug/Aurelius.app"

cd "$ROOT"

echo "→ Building for macOS..."
xcodebuild \
  -scheme "$SCHEME" \
  -destination "platform=macOS" \
  -derivedDataPath "$DERIVED_DATA" \
  build

echo "→ Launching Aurelius..."
pkill -x Aurelius 2>/dev/null || true
open "$APP_PATH"
