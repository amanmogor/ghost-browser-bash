#!/bin/bash
# 🔧 GHOST ULTIMATE INSTALLER
# Auto-setup for Linux / Kali / iSH / a-Shell

echo "🛠️ Installing Ghost Ultimate Toolkit..."

# === Detect platform ===
PLATFORM=""
if uname -a | grep -iq kali; then
  PLATFORM="kali"
elif uname -a | grep -iq linux; then
  PLATFORM="linux"
elif uname -a | grep -iq ish; then
  PLATFORM="ish"
elif uname -a | grep -iq shell; then
  PLATFORM="ashell"
else
  echo "⚠️ Unknown platform. Proceeding as Linux fallback."
  PLATFORM="unknown"
fi

# === Create folders ===
mkdir -p ~/.ghost/logs

# === Copy script ===
cp ghost.sh ~/.ghost/
chmod +x ~/.ghost/ghost.sh

# === Install dependencies ===
if [[ "$PLATFORM" == "kali" || "$PLATFORM" == "linux" ]]; then
  echo "📦 Installing dependencies for Linux/Kali..."
  sudo apt update && sudo apt install curl tor nodejs npm -y
  echo "📦 Installing stealth automation tools..."
  npm install -g puppeteer puppeteer-extra puppeteer-extra-plugin-stealth wrtc
elif [[ "$PLATFORM" == "ish" || "$PLATFORM" == "ashell" ]]; then
  echo "📦 iOS Shell Detected – skipping Node, Tor..."
else
  echo "⚠️ Could not verify environment."
fi

# === Add CLI shortcut ===
echo "🔗 Creating launch alias..."
if [[ -n "$HOME/.bashrc" ]]; then
  echo 'alias ghost="bash ~/.ghost/ghost.sh"' >> ~/.bashrc
  source ~/.bashrc
elif [[ -n "$HOME/.zshrc" ]]; then
  echo 'alias ghost="bash ~/.ghost/ghost.sh"' >> ~/.zshrc
  source ~/.zshrc
fi

echo "✅ Ghost Toolkit installed successfully!"
echo "🚀 Run it anytime using: ghost"
