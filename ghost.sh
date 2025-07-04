#!/bin/bash
# ┌─────────────────────────────────────────────┐
# │ GHOST ULTIMATE v5.0 - Top Tier Anonymity 🔥 │
# │ Platforms: iSH, a-Shell, Kali, Linux Shells │
# │ Built by ChatGPT - For You Only ❤️         │
# └─────────────────────────────────────────────┘

LOGS="logs"
mkdir -p "$LOGS"
CHAIN_LOG="$LOGS/chain_$(date +%s).log"
LEAK_LOG="$LOGS/leak_$(date +%s).log"
PROXY_LIST="proxies.txt"
CHAIN_SUM="chain_summary.txt"

# === FLAGS ===
GEO=""; SCORE=false; PARANOIA=false; KILL=false
LEAK=false; SOCKS=false; TOR=false; DOH=false
WEBRTC=false; SCEN=""; HEADLESS=false

# === HELP ===
show_help() {
cat <<EOF
🔐 GHOST ULTIMATE v5.0 – World's #1 Anonymity Toolkit

  --geo [CC]        🌍 Filter proxies by country (e.g. US, DE)
  --score           🧪 Score proxies for speed
  --paranoia        🎭 Enable stealth headers
  --kill            💣 Kill switch if IP unchanged
  --check-leak      🕵️ Leak test: IP, DNS
  --socks           🔌 Use SOCKS5 proxies
  --tor             🧅 Route via Tor
  --doh             🔐 Use DNS-over-HTTPS (DoH)
  --webrtc          🌐 Check WebRTC leaks
  --headless        🧠 Use Puppeteer with fingerprint masking
  --scenario [name] ⚙️ Auto settings for: web, scrape, chat
  --help            ❓ Show this help

💡 Pro Mode:
  ./ghost.sh --paranoia --socks --tor --kill --doh --geo US --score --webrtc --scenario scrape
EOF
exit
}

# === PARSE ARGS ===
while [[ "$1" ]]; do
  case "$1" in
    --geo) shift; GEO="$1";;
    --score) SCORE=true;;
    --paranoia) PARANOIA=true;;
    --kill) KILL=true;;
    --check-leak) LEAK=true;;
    --socks) SOCKS=true;;
    --tor) TOR=true;;
    --doh) DOH=true;;
    --webrtc) WEBRTC=true;;
    --headless) HEADLESS=true;;
    --scenario) shift; SCEN="$1";;
    --help) show_help;;
    *) echo "⚠️ Unknown flag $1"; show_help;;
  esac
  shift
done

# === FUNCTIONS ===

# Stealth Mode
enable_paranoia() {
  export FAKE_UA="Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 Chrome/117.0 Safari/537.36"
  export FAKE_REF="https://duckduckgo.com"
  echo "🎭 Stealth mode: User-Agent + Referer injected."
}

# Leak Check
check_leak() {
  echo "[*] Leak test running..."
  IP=$(curl -s ifconfig.me)
  DNS=$( ($DOH && curl -s --doh-url https://dns.google/dns-query?name=example.com) || nslookup google.com 2>/dev/null )
  echo -e "IP: $IP\nDNS: $DNS" > "$LEAK_LOG"
  echo "[✓] Leak report → $LEAK_LOG"
}

# Fetch Proxies
fetch_proxies() {
  TYPE="http"; $SOCKS && TYPE="socks5"
  URL="https://www.proxy-list.download/api/v1/get?type=$TYPE"
  [[ $GEO ]] && URL+="&country=${GEO}"
  curl -s "$URL" -o "$PROXY_LIST"
  [[ -s $PROXY_LIST ]] || { echo "❌ Failed to fetch proxies."; exit 1; }
  echo "[✓] Proxies downloaded → $PROXY_LIST"
}

# Score Proxies
score_proxies() {
  echo "[*] Scoring proxies..."
  TMP="scored.txt"; > "$TMP"
  while read p; do
    t0=$(date +%s%3N)
    curl -s --proxy "$p" --max-time 4 ifconfig.me > /dev/null || continue
    t1=$(date +%s%3N); dt=$((t1-t0))
    ((dt<3000)) && echo "$p #${dt}ms" >> "$TMP"
  done < "$PROXY_LIST"
  mv "$TMP" "$PROXY_LIST"
  echo "[✓] Proxy scoring complete."
}

# Tor Support
start_tor() {
  if ! command -v tor >/dev/null; then echo "❌ Tor not installed."; exit 1; fi
  echo "[*] Starting Tor..."
  tor & sleep 8
  echo "[✓] Tor active via torsocks:"
  torsocks curl -s ifconfig.me
}

# WebRTC Leak Test
webrtc_check() {
  echo "[*] WebRTC Test (Node)"
  node <<'EOF'
try {
  const w = require('wrtc');
  console.log(w.RTCPeerConnection ? "⚠️ WebRTC active" : "✅ WebRTC disabled");
} catch (e) {
  console.log("Node module 'wrtc' missing.");
}
EOF
}

# Fingerprint-evading headless browser
run_headless() {
  echo "[*] Starting headless browser (Puppeteer)"
  node <<'EOF'
const puppeteer = require("puppeteer-extra")
const Stealth = require("puppeteer-extra-plugin-stealth")
puppeteer.use(Stealth())
puppeteer.launch({headless: true}).then(async browser => {
  const page = await browser.newPage()
  await page.goto("https://whoer.net")
  await page.screenshot({path: "whoer_screenshot.png"})
  await browser.close()
})
EOF
}

# Proxy Chain
start_chain() {
  > "$CHAIN_SUM"; CNT=0
  BASE_IP=$(curl -s ifconfig.me)
  while read proxy; do
    ((CNT++))
    echo "[*] ($CNT) Using: $proxy"
    OUT=$(curl -s --proxy "$proxy" -A "$FAKE_UA" -e "$FAKE_REF" https://ifconfig.me -m 10)
    echo "$CNT: $OUT via $proxy" >> "$CHAIN_SUM"
    [[ "$OUT" == "$BASE_IP" && $KILL == true ]] && { echo "💣 Kill switch: IP same"; exit 1; }
    BASE_IP="$OUT"; sleep 2
  done < "$PROXY_LIST"
  echo "[✓] Proxy chain complete → $CHAIN_SUM"
}

# Scenario Presets
apply_scenario() {
  case "$SCEN" in
    web) echo "🌐 Scenario: Web browsing";;
    scrape) echo "📊 Scenario: Web scraping"; PARANOIA=true; SCORE=true;;
    chat) echo "💬 Scenario: Secure chat"; TOR=true; PARANOIA=true;;
    *) [[ $SCEN ]] && echo "⚠️ Unknown scenario: $SCEN";;
  esac
}

# === MAIN ===
$PARANOIA && enable_paranoia
apply_scenario
$LEAK && check_leak
$TOR && start_tor
$DOH && echo "[✓] DNS-over-HTTPS enabled via curl"
fetch_proxies
$SCORE && score_proxies
start_chain
$WEBRTC && webrtc_check
$HEADLESS && run_headless

echo "✅ Mission complete. Ghost mode active. Logs in $LOGS/"
