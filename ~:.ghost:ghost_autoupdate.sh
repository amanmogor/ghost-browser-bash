#!/bin/bash
# 🔄 Ghost Ultimate Auto-Updater

# === Config ===
REPO_URL="https://raw.githubusercontent.com/YOUR-GITHUB-USERNAME/ghost-toolkit/main/ghost.sh"
LOCAL_SCRIPT="$HOME/.ghost/ghost.sh"
TMP_SCRIPT="/tmp/ghost_new.sh"

echo "🔍 Checking for updates..."

# === Fetch remote script ===
curl -s "$REPO_URL" -o "$TMP_SCRIPT" || { echo "❌ Could not fetch update."; exit 1; }

# === Extract versions ===
REMOTE_VER=$(grep -m1 '^# │ GHOST ULTIMATE v' "$TMP_SCRIPT" | grep -oP 'v[\d.]+' || echo "v0.0")
LOCAL_VER=$(grep -m1 '^# │ GHOST ULTIMATE v' "$LOCAL_SCRIPT" | grep -oP 'v[\d.]+' || echo "v0.0")

echo "🔹 Local Version : $LOCAL_VER"
echo "🔹 Remote Version: $REMOTE_VER"

# === Version comparison ===
if [[ "$REMOTE_VER" != "$LOCAL_VER" ]]; then
  echo "🚀 Updating to $REMOTE_VER..."
  mv "$TMP_SCRIPT" "$LOCAL_SCRIPT"
  chmod +x "$LOCAL_SCRIPT"
  echo "✅ Update complete! Run: ghost --help"
else
  echo "✅ You already have the latest version."
  rm "$TMP_SCRIPT"
fi
