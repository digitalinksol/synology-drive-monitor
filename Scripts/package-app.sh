#!/bin/bash
# Assemble a local Unstuckerator.app and ad-hoc sign it.
# Usage: Scripts/package-app.sh [destination.app]
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
DEST="${1:-$HOME/Applications/Unstuckerator.app}"
CONFIGURATION="${CONFIGURATION:-release}"

swift build --package-path "$ROOT" --configuration "$CONFIGURATION" --product Unstuckerator
BIN_DIR="$(swift build --package-path "$ROOT" --configuration "$CONFIGURATION" --product Unstuckerator --show-bin-path)"
BIN="$BIN_DIR/Unstuckerator"

if [[ ! -x "$BIN" ]]; then
  echo "Build did not produce $BIN" >&2
  exit 1
fi

mkdir -p "$DEST/Contents/MacOS" "$DEST/Contents/Resources"
cp "$ROOT/AppLauncher/Info.plist" "$DEST/Contents/Info.plist"
cp "$ROOT/App/Resources/AppIcon.icns" "$DEST/Contents/Resources/AppIcon.icns"
cp "$ROOT/App/Resources/DockMark.png" "$DEST/Contents/Resources/DockMark.png"
cp "$BIN" "$DEST/Contents/MacOS/Unstuckerator"
chmod +x "$DEST/Contents/MacOS/Unstuckerator"
codesign --force --sign - "$DEST"
echo "Built $DEST"

# OPEN=0 builds the app without quitting a copy that is already running.
if [[ "${OPEN:-1}" == "1" ]]; then
  # Replace only this app. Never signal fileproviderd or Synology.
  if pgrep -x Unstuckerator >/dev/null; then
    killall Unstuckerator || true
    sleep 0.4
  fi
  # Launch Services often returns -600 on the first open right after signing.
  open "$DEST" || true
  sleep 1
  open "$DEST"
fi
