#!/bin/bash

# -----------------------------------------------------------------------------
# Script Name: uptime-watcher.sh
# Description: Monitor the uptime of multiple hosts (domain/IP) listed in a file.
#              Sends email alerts if any host is down. Can be run silently or
#              log activity for background execution.
#
# Usage:
#   ./uptime-watcher.sh -f hosts.txt -i 5 --log
#   ./uptime-watcher.sh -f hosts.txt --silent
#
# Flags:
#   -f | --file     : Input file containing domain/IP (one per line)
#   -i | --interval : Interval in minutes (default: 5)
#   --log           : Enable logging to uptime-watcher.log
#   --silent        : No output to stdout
#
# Dependencies: curl, ping, mailx or sendmail (for alerts)
# -----------------------------------------------------------------------------

# Defaults
INTERVAL=5
LOG=false
SILENT=false
HOST_FILE=""
LOG_FILE="uptime-watcher.log"
EMAIL_RECIPIENT="you@example.com"  # Set your alert email here

# --- Function to log messages ---
log() {
    local msg="$1"
    if [ "$LOG" = true ]; then
        echo "$(date '+%Y-%m-%d %H:%M:%S') : $msg" >> "$LOG_FILE"
    fi
    if [ "$SILENT" = false ]; then
        echo "$msg"
    fi
}

# --- Function to send alerts ---
send_alert() {
    local host="$1"
    local method="$2"
    local subject="🔴 ALERT: Host down - $host"
    local body="[$(date)] The host $host is unreachable via $method check."

    echo "$body" | mailx -s "$subject" "$EMAIL_RECIPIENT"
}

# --- Function to check host status ---
check_host() {
    local host="$1"
    if ping -c 1 -W 3 "$host" > /dev/null 2>&1; then
        log "✅ $host is reachable (ping)"
    else
        log "❌ $host is unreachable (ping)"
        send_alert "$host" "ping"
    fi
}

# --- Parse arguments ---
while [[ "$#" -gt 0 ]]; do
    case "$1" in
        -f|--file) HOST_FILE="$2"; shift ;;
        -i|--interval) INTERVAL="$2"; shift ;;
        --log) LOG=true ;;
        --silent) SILENT=true ;;
        *) echo "Unknown parameter passed: $1"; exit 1 ;;
    esac
    shift
done

# --- Validations ---
if [[ -z "$HOST_FILE" || ! -f "$HOST_FILE" ]]; then
    echo "Error: Input file not specified or does not exist."
    exit 1
fi

log "📡 Starting uptime watcher (interval: $INTERVAL min)"
log "📄 Monitoring hosts from $HOST_FILE"

# --- Infinite Watch Loop ---
while true; do
    while IFS= read -r host; do
        [[ -z "$host" ]] && continue
        check_host "$host"
    done < "$HOST_FILE"

    log "⏳ Sleeping for $INTERVAL minute(s)..."
    sleep "${INTERVAL}m"
done
