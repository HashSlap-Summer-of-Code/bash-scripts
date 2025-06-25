#!/bin/bash

# ──────────────────────────────────────────────────────────────
# Script: file-type-backup.sh
# Description: Recursively searches for specified file types and copies
#              them to a timestamped backup directory.
# Options:
#   -d <directory>   Target directory to scan (default: current directory)
#   -t <types>       File types to include (comma-separated, e.g., pdf,docx,jpg)
#   -v               Verbose mode (prints each file being copied)
#   -n               Dry-run (simulate copy without actually copying)
# Usage:
#   ./file-type-backup.sh -d ~/Documents -t pdf,jpg -v -n
# ──────────────────────────────────────────────────────────────

TARGET_DIR="."
FILE_TYPES="pdf,docx,jpg"
VERBOSE=false
DRY_RUN=false

while getopts "d:t:vn" opt; do
  case $opt in
    d) TARGET_DIR="$OPTARG" ;;
    t) FILE_TYPES="$OPTARG" ;;
    v) VERBOSE=true ;;
    n) DRY_RUN=true ;;
    *) echo "Usage: $0 [-d directory] [-t types] [-v] [-n]" >&2; exit 1 ;;
  esac
done

TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="./backup_$TIMESTAMP"
EXTENSIONS=$(echo "$FILE_TYPES" | tr ',' '\n')

mkdir -p "$BACKUP_DIR"

echo "🔍 Searching in: $TARGET_DIR"
echo "📁 Backup folder: $BACKUP_DIR"
echo "📄 File types: $FILE_TYPES"
echo "🧪 Dry-run mode: $DRY_RUN"
echo "📢 Verbose: $VERBOSE"
echo

for EXT in $EXTENSIONS; do
  FILES=$(find "$TARGET_DIR" -type f -iname "*.$EXT")
  for FILE in $FILES; do
    DEST="$BACKUP_DIR/$(basename "$FILE")"
    $VERBOSE && echo "Copying: $FILE → $DEST"
    if [ "$DRY_RUN" = false ]; then
      cp "$FILE" "$DEST"
    fi
  done
done

echo "✅ Backup completed (or simulated if dry-run)."
