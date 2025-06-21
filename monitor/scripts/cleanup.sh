#!/bin/bash

# Log cleanup utility
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DATA_DIR="${SCRIPT_DIR}/../data"
LOG_DIR="${SCRIPT_DIR}/../logs"
DAYS_TO_KEEP=7

echo "Cleaning up old log files (keeping last ${DAYS_TO_KEEP} days)..."

# Remove old CSV files
find "$DATA_DIR" -name "system_stats_*.csv" -type f -mtime +${DAYS_TO_KEEP} -delete

# Remove old log files
find "$LOG_DIR" -name "*.log" -type f -mtime +${DAYS_TO_KEEP} -delete

echo "Cleanup complete!"