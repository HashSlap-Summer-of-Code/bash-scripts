#!/bin/bash

# ============================================================
# Script Name : disk-usage-analyzer.sh
# Description : Displays disk usage for root (/) and home (~)
#               directories in human-readable format.
#               Lists number of files/folders and warns if
#               disk usage exceeds 80%.
# Usage       : bash disk-usage-analyzer.sh
# Tools Used  : df, tput, find, date
# ============================================================

# ⏱ Start time
START=$(date +%s)
TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")

echo "📦 Disk Usage Report"
echo "===================="
echo "🕒 Generated on: $TIMESTAMP"

# Function to color usage % if high
color_usage() {
  local usage=$1
  if [ "$usage" -ge 90 ]; then
    echo -n "$(tput setaf 1)${usage}%$(tput sgr0)" # Red
  elif [ "$usage" -ge 80 ]; then
    echo -n "$(tput setaf 3)${usage}%$(tput sgr0)" # Yellow
  else
    echo -n "${usage}%"
  fi
}

# 📁 Root directory usage
echo -e "\n📁 Root Directory (/):"
df -h / | awk 'NR==1 || NR==2' | while read -r line; do
  if [[ "$line" =~ ([0-9]+)% ]]; then
    usage=${BASH_REMATCH[1]}
    line=${line//${usage}%/$(color_usage "$usage")}
  fi
  echo "$line"
done

# 🏠 Home directory usage
echo -e "\n🏠 Home Directory (~):"
df -h ~ | awk 'NR==1 || NR==2' | while read -r line; do
  if [[ "$line" =~ ([0-9]+)% ]]; then
    usage=${BASH_REMATCH[1]}
    line=${line//${usage}%/$(color_usage "$usage")}
  fi
  echo "$line"
done

# ⏱ Time taken
END=$(date +%s)
DURATION=$((END - START))
echo -e "\n✅ Report generated in ${DURATION}s."
