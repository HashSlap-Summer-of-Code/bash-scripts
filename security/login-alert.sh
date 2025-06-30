#!/bin/bash

# login-alert.sh — Monitor for failed SSH login attempts
# Watches /var/log/auth.log and logs suspicious login attempts
# Optional: Uses notify-send for desktop alerts if available

LOG_FILE="/var/log/auth.log"  # Change to /var/log/secure for RHEL/CentOS
OUTPUT_LOG="$HOME/login_warnings.txt"

echo "🔍 Monitoring SSH login attempts..."
echo "Writing suspicious activity to $OUTPUT_LOG"

# Ensure output log exists
touch "$OUTPUT_LOG"

# Function to send notification (if GUI/notify-send available)
send_notification() {
    local msg="$1"
    if command -v notify-send &> /dev/null; then
        notify-send "SSH Alert" "$msg"
    fi
    logger -p auth.warning "$msg"
}

# Monitor log file for failed SSH attempts
tail -Fn0 "$LOG_FILE" | while read -r line; do
    if echo "$line" | grep -qi "Failed password"; then
        TIMESTAMP=$(echo "$line" | awk '{print $1, $2, $3}')
        IP=$(echo "$line" | grep -oE 'from ([0-9]{1,3}\.){3}[0-9]{1,3}' | awk '{print $2}')
        USER=$(echo "$line" | grep -oP "for (invalid user )?\K\S+")

        MESSAGE="⚠️ Failed SSH login: user=$USER, ip=$IP, time=$TIMESTAMP"
        echo "$MESSAGE" >> "$OUTPUT_LOG"
        echo "$MESSAGE"

        send_notification "$MESSAGE"
    fi
done
