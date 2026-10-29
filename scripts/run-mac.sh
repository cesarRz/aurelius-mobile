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
if pgrep -x Aurelius >/dev/null; then
  pkill -x Aurelius || true
  while pgrep -x Aurelius >/dev/null; do sleep 0.1; done
fi
open "$APP_PATH"
