#!/bin/bash

# ==============================================================================
# Script Name: log-cleaner.sh
# Description: 
#   - Searches for .log files in /var/log
#   - Prints their size and last modified date
#   - Optionally deletes files older than 7 days (with user confirmation)
# Usage: 
#   Run as sudo/root: ./log-cleaner.sh
# ==============================================================================

LOG_DIR="/var/log"
DAYS_OLD=7

echo "🔍 Searching for .log files in $LOG_DIR..."
echo

find "$LOG_DIR" -type f -name "*.log" | while read -r logfile; do
    size=$(du -h "$logfile" | cut -f1)
    mod_date=$(stat -c %y "$logfile" | cut -d'.' -f1)
    echo "📄 File: $logfile"
    echo "   Size: $size"
    echo "   Last Modified: $mod_date"
    echo
done

echo "⚠️  Do you want to delete .log files older than $DAYS_OLD days? (y/n)"
read -r confirm
if [[ "$confirm" =~ ^[Yy]$ ]]; then
    echo "🧹 Deleting files older than $DAYS_OLD days..."
    sudo find "$LOG_DIR" -type f -name "*.log" -mtime +$DAYS_OLD -exec rm -v {} \;
    echo "✅ Cleanup complete."
else
    echo "❌ Skipping deletion."
fi
