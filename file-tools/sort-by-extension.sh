#!/bin/bash

# -----------------------------------------------------------------------------
# 📁 File: sort-by-extension.sh
# 📌 Description: Sorts all files in a directory into subfolders based on their
#     file extensions (case-insensitive). Helps organize messy folders like Downloads.
#
# 🛠️ Tools Used: find, mv, mkdir, basename, tr, mapfile
# 💬 Interactive version: Displays progress and summary (fixed subshell bug)
#
# 📂 Example:
#   📄 resume.pdf → PDF/resume.pdf
#   📄 image.JPG → JPG/image.JPG
#   📄 script.sh → SH/script.sh
#   📄 LICENSE   → NOEXT/LICENSE
#
# 🧪 Usage:
#   bash sort-by-extension.sh <target-directory>
#
# Example:
#   bash sort-by-extension.sh ~/Downloads
#
# Author: Surge77
# -----------------------------------------------------------------------------

# 🎯 Step 1: Validate directory input
if [ -z "$1" ]; then
  echo "🚨 Usage: $0 <target-directory>"
  exit 1
fi

TARGET_DIR="$1"

# 🎯 Step 2: Check if the directory exists
if [ ! -d "$TARGET_DIR" ]; then
  echo "❌ Error: Directory not found — $TARGET_DIR"
  exit 1
fi

echo "🔍 Scanning directory: $TARGET_DIR"
echo "📦 Sorting files into folders by extension..."

# 🔢 Step 3: Initialize counters and extension set
file_count=0
folder_count=0
ext_set=()

# 🧠 Step 4: Load all files into an array (to avoid subshell issues)
mapfile -t files < <(find "$TARGET_DIR" -maxdepth 1 -type f)

# 🔁 Step 5: Loop through the file list
for file in "${files[@]}"; do
  filename=$(basename "$file")           # Extract just the filename
  ext="${filename##*.}"                  # Get the extension

  # 🧪 Handle files without an extension
  if [ "$filename" = "$ext" ]; then
    folder="NOEXT"
  else
    folder=$(echo "$ext" | tr '[:lower:]' '[:upper:]')  # Normalize to uppercase
  fi

  # 🔍 Track unique folders/extensions
  if [[ ! " ${ext_set[*]} " =~ " ${folder} " ]]; then
    ext_set+=("$folder")
    ((folder_count++))
  fi

  # 📂 Create the folder if not present and move file
  mkdir -p "$TARGET_DIR/$folder"
  mv "$file" "$TARGET_DIR/$folder/"
  echo "✅ Moved: $filename → $folder/"
  ((file_count++))
done

# 📊 Final Summary
echo
echo "🎉 Sorting complete!"
echo "📁 Total folders created: $folder_count"
echo "📄 Total files moved: $file_count"
echo "🗂️  Extensions organized into: ${ext_set[*]}"
