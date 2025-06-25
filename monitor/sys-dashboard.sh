#!/usr/bin/env bash
# -----------------------------------------------------------------------------
# sys-dashboard.sh — Interactive terminal-based system info dashboard
#
# Author: Surge77
#
# Description:
#   This script displays a neatly formatted summary of your system's status.
#   It shows OS details, CPU load, memory, disk, network info, and running services.
#   The user interacts by pressing ENTER to reveal each section.
#
# Prerequisites:
#   bash, tput, uname, uptime, awk, free, df, ip, ss, systemctl
#   (Optional: figlet for fancy banners)
# -----------------------------------------------------------------------------

# ░█▀▀░█▀█░█▀█░█░█░█▀█░█░█░█▀▀
# ░▀▀█░█▀█░█░█░█░█░█░█░█░█░▀▀█
# ░▀▀▀░▀░▀░▀░▀░▀▀▀░▀▀▀░▀▀▀░▀▀▀

# Exit script immediately on error (-e),
# treat unset variables as an error (-u),
# and fail pipelines if any command fails (-o pipefail)
set -euo pipefail
IFS=$'\n\t' # Safer word splitting

# Check if `figlet` is available. If not, fallback to text banner.
FIGLET_CMD=$(command -v figlet || echo "")

# ═════════════════════════════════════════════════════════════
# Function: Display a centered banner with or without figlet
# ═════════════════════════════════════════════════════════════
print_title() {
    tput setaf 2; tput bold  # Set text to bold green
    if [[ -n "$FIGLET_CMD" ]]; then
        "$FIGLET_CMD" -w 80 "SYS DASHBOARD"
    else
        printf "\n%*s\n\n" $(( (80 + 12) / 2 )) "SYS DASHBOARD"
    fi
    tput sgr0  # Reset formatting
}

# ═════════════════════════════════════════════════════════════
# Function: Print a blue section header
# ═════════════════════════════════════════════════════════════
section() {
    tput setaf 4; tput bold
    echo -e "\n▶ $1"
    tput sgr0
}

# ═════════════════════════════════════════════════════════════
# Function: Pause and wait for user to press ENTER
# ═════════════════════════════════════════════════════════════
pause() {
    tput setaf 3  # Yellow
    read -rp "Press ENTER to continue..."
    tput sgr0
}

# ═════════════════════════════════════════════════════════════
# Section: Basic OS & Kernel Info
# ═════════════════════════════════════════════════════════════
get_os_info() {
    local os kernel
    os=$(uname -o)         # e.g., GNU/Linux
    kernel=$(uname -r)     # e.g., 5.15.123-WSL2
    echo "Operating System : $os"
    echo "Kernel Version   : $kernel"
}

# ═════════════════════════════════════════════════════════════
# Section: Uptime (how long system has been running)
# ═════════════════════════════════════════════════════════════
get_uptime() {
    uptime -p  # e.g., "up 1 hour, 3 minutes"
}

# ═════════════════════════════════════════════════════════════
# Section: CPU load (recent activity)
# ═════════════════════════════════════════════════════════════
get_cpu_load() {
    # Get the 1-minute load average from `uptime` output
    awk '{gsub(/,/, ""); print "CPU Load (1 min):", $10}' <(uptime)
}

# ═════════════════════════════════════════════════════════════
# Section: Memory usage (RAM)
# ═════════════════════════════════════════════════════════════
get_mem_usage() {
    # Use `free` to show RAM usage in human-readable format
    free -h | awk 'NR==2 {printf "RAM Usage: %s / %s\n", $3, $2}'
}

# ═════════════════════════════════════════════════════════════
# Section: Disk usage per mounted partition
# ═════════════════════════════════════════════════════════════
get_disk_usage() {
    # Show mount point and usage %, formatted nicely
    df -h --output=target,pcent | awk 'NR==1 || $2+0 >= 0 {printf "%-25s %s\n", $1, $2}'
}

# ═════════════════════════════════════════════════════════════
# Section: Show local IP addresses
# ═════════════════════════════════════════════════════════════
get_ip_address() {
    # Show IPv4 addresses for real interfaces
    ip -4 addr show scope global | awk '/inet /{print $2 " on " $NF}'
}

# ═════════════════════════════════════════════════════════════
# Section: Active TCP/UDP connections
# ═════════════════════════════════════════════════════════════
get_active_conns() {
    # Use `ss` instead of deprecated `netstat`
    local count
    count=$(ss -tun state established | wc -l)
    echo "Active TCP/UDP connections: $count"
}

# ═════════════════════════════════════════════════════════════
# Section: Running services (systemd only)
# ═════════════════════════════════════════════════════════════
get_running_services() {
    systemctl list-units --type=service --state=running --no-pager \
      | awk 'NR>1 && /loaded/ {print "• " $1}'
}

# ═════════════════════════════════════════════════════════════
# MAIN FUNCTION — Calls all others in a sequence
# ═════════════════════════════════════════════════════════════
main() {
    clear
    print_title

    section "System Information"
    echo "Showing basic OS and kernel details..."
    get_os_info
    echo "System Uptime: $(get_uptime)"
    pause

    section "Performance Metrics"
    echo "Fetching CPU load..."
    get_cpu_load
    echo "Fetching RAM usage..."
    get_mem_usage
    pause

    section "Disk Usage"
    echo "Gathering mount points and disk usage..."
    get_disk_usage
    pause

    section "Network Info"
    echo "Your system IP addresses:"
    get_ip_address
    echo "Counting active connections..."
    get_active_conns
    pause

    section "Running Services"
    echo "Listing currently active services:"
    get_running_services
    pause

    tput setaf 2; tput bold
    echo -e "\n✅ Done! System dashboard complete."
    tput sgr0
}

main
exit 0
