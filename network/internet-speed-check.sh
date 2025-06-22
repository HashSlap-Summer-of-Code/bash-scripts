#!/bin/bash

# -----------------------------------------------------------------------------
# internet-speed-check.sh
#
# 📡 Internet Speed Test Script
# Checks if 'speedtest-cli' is installed. Runs a speed test and prints Download,
# Upload, and Ping values. If not installed, shows installation instructions.
#
# 🛠 Dependencies: speedtest-cli
# 🗂️ Category: Network Tools
#
# Usage:
#   bash internet-speed-check.sh
#
# Author: Surge77
# -----------------------------------------------------------------------------

echo ""
echo "👋 Welcome to the Internet Speed Test!"
echo "This script will measure your current internet download and upload speeds, as well as your ping (latency)."
echo "---------------------------------------------------------"

print_install_instructions() {
    echo ""
    echo "⚠️  'speedtest-cli' is not installed."
    echo "To install it, run one of the following commands based on your OS:"
    echo "  sudo apt update && sudo apt install speedtest-cli   # Debian/Ubuntu"
    echo "  sudo dnf install speedtest-cli                      # Fedora"
    echo "  brew install speedtest-cli                          # Mac/Homebrew"
    echo "  pip install speedtest-cli                           # Any OS (via pip)"
    echo ""
}

# Check if speedtest-cli is installed
if ! command -v speedtest-cli &> /dev/null; then
    print_install_instructions
    exit 1
fi

# Spinner function (runs in background)
spin() {
    local -a marks=('-' '\' '|' '/')
    while :; do
        for mark in "${marks[@]}"; do
            printf "\r⏳ Running speed test... Please wait %s " "$mark"
            sleep 0.2
        done
    done
}

# Start spinner in background, save its PID
spin &
SPIN_PID=$!

# Try the simple output style (older versions)
output=$(speedtest-cli --simple 2>/dev/null)

if [[ -z "$output" ]]; then
    # Try new output style with --accept-license --accept-gdpr flags (newer versions)
    output=$(speedtest-cli --accept-license --accept-gdpr 2>/dev/null)
fi

# Stop the spinner
kill "$SPIN_PID" 2>/dev/null
wait "$SPIN_PID" 2>/dev/null

echo ""  # Move to a new line after spinner

# If still nothing, show an error and exit
if [[ -z "$output" ]]; then
    echo "❌ Could not run speedtest-cli. Please check your internet connection or try updating speedtest-cli."
    exit 2
fi

echo "✅ Speed test complete! Here are your results:"

# Attempt to extract Download, Upload, and Ping from whatever output we get
download=$(echo "$output" | grep -i "Download" | head -1 | awk '{for(i=1;i<=NF;i++) if ($i ~ /[0-9.]+/) {print $i, $(i+1); exit}}')
upload=$(echo "$output" | grep -i "Upload" | head -1 | awk '{for(i=1;i<=NF;i++) if ($i ~ /[0-9.]+/) {print $i, $(i+1); exit}}')
ping=$(echo "$output" | grep -i "Ping" | head -1 | awk '{for(i=1;i<=NF;i++) if ($i ~ /[0-9.]+/) {print $i, $(i+1); exit}}')

# Handle empty values for clarity
[ -z "$download" ] && download="N/A"
[ -z "$upload" ] && upload="N/A"
[ -z "$ping" ] && ping="N/A"

echo "------------------------------------------"
echo "   📡 Internet Speed Test Results"
echo "------------------------------------------"
echo "🔽 Download Speed : $download"
echo "🔼 Upload Speed   : $upload"
echo "⏱️  Ping           : $ping"
echo "------------------------------------------"
echo ""
echo "🌐 Tip: If you want to compare speeds at different times, try running this script again later!"
