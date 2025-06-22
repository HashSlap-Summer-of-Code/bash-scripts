#!/bin/bash

# ============================================================
# Script Name : disk-usage-analyzer.sh
# Description : Displays disk usage for root (/) and home (~)
#               directories in human-readable format.
#               Optionally lists top 5 largest files/directories.
# Usage       : bash disk-usage-analyzer.sh
# Tools Used  : df, du, sort, head
# ============================================================

echo "📦 Disk Usage Report"
echo "===================="

# Root directory usage
echo -e "\n📁 Root Directory (/):"
df -h / | awk 'NR==1 || NR==2'

# Home directory usage
echo -e "\n🏠 Home Directory (~):"
df -h ~ | awk 'NR==1 || NR==2'

# Optional: Top 5 largest files/folders in Home
echo -e "\n🔍 Top 5 Largest Files/Folders in Home (~):"
du -ah ~ 2>/dev/null | sort -hr | head -n 5
