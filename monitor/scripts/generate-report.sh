#!/bin/bash

# Report generation utility
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DATA_DIR="${SCRIPT_DIR}/../data"
OUTPUT_DIR="${SCRIPT_DIR}/../output"

# Find latest CSV file
LATEST_CSV=$(find "$DATA_DIR" -name "system_stats_*.csv" -type f -printf '%T@ %p\n' | sort -n | tail -1 | cut -d' ' -f2-)

if [ -z "$LATEST_CSV" ]; then
    echo "No CSV files found in $DATA_DIR"
    exit 1
fi

echo "Generating reports for: $LATEST_CSV"

# Generate summary statistics
echo "=== System Monitor Summary ===" > "${OUTPUT_DIR}/summary.txt"
echo "Data file: $(basename "$LATEST_CSV")" >> "${OUTPUT_DIR}/summary.txt"
echo "Records: $(wc -l < "$LATEST_CSV")" >> "${OUTPUT_DIR}/summary.txt"
echo "" >> "${OUTPUT_DIR}/summary.txt"

# Calculate averages using awk
awk -F',' '
NR > 1 {
    cpu_sum += $2; mem_sum += $3; disk_sum += $4; load_sum += $7; count++
}
END {
    if (count > 0) {
        printf "Average CPU: %.2f%%\n", cpu_sum/count
        printf "Average Memory: %.2f%%\n", mem_sum/count
        printf "Average Disk: %.2f%%\n", disk_sum/count
        printf "Average Load: %.2f\n", load_sum/count
    }
}' "$LATEST_CSV" >> "${OUTPUT_DIR}/summary.txt"

echo "Summary report generated: ${OUTPUT_DIR}/summary.txt"