#!/bin/bash
# Awaaz installer: downloads the latest Awaaz, puts it in Applications and opens it.
# Downloading with curl means macOS does not mark the app as "from the internet",
# so there is no "Apple could not verify" box.
set -euo pipefail
URL="https://github.com/Dito005/awaaz/releases/latest/download/Awaaz.dmg"
TMP="$(mktemp -d)"
cleanup() { [ -n "${MNT:-}" ] && hdiutil detach "$MNT" -quiet 2>/dev/null || true; rm -rf "$TMP"; }
trap cleanup EXIT

echo ""
echo "  Installing Awaaz…"
echo ""
curl -fL --progress-bar -o "$TMP/Awaaz.dmg" "$URL"
MNT="$(hdiutil attach -nobrowse -readonly -noautoopen "$TMP/Awaaz.dmg" | tail -1 | awk -F'\t' '{print $NF}')"

pkill -x Awaaz 2>/dev/null || true
sleep 1
if [ -w /Applications ]; then
  rm -rf /Applications/Awaaz.app
  cp -R "$MNT/Awaaz.app" /Applications/
  xattr -dr com.apple.quarantine /Applications/Awaaz.app 2>/dev/null || true
else
  echo "  Your Mac needs your password to add Awaaz to Applications:"
  sudo rm -rf /Applications/Awaaz.app
  sudo cp -R "$MNT/Awaaz.app" /Applications/
  sudo xattr -dr com.apple.quarantine /Applications/Awaaz.app 2>/dev/null || true
fi

open /Applications/Awaaz.app
echo ""
echo "  ✓ Awaaz is installed and opening now. Follow the setup on screen."
echo ""
