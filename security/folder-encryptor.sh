#!/bin/bash

# -----------------------------------------------------------------------------
# 📁 File: folder-encryptor.sh
# 📌 Description: Compresses a folder into a .tar file and encrypts it using
#     AES-256 encryption via OpenSSL. Prompts user for password securely.
#
# 🛠 Tools Used: tar, openssl, read -s, basename
# 💬 Interactive, safe, beginner-friendly
#
# 🧪 Usage:
#   bash folder-encryptor.sh <folder-path>
#
# Example:
#   bash folder-encryptor.sh ~/Documents/myFolder
#
# Output:
#   Creates an encrypted file like: myFolder.tar.enc
#
# Author: Surge77
# -----------------------------------------------------------------------------

set -e  # ❗ Exit immediately if any command fails

# 🎯 Step 1: Validate input
if [ -z "$1" ]; then
  echo "🚨 Usage: $0 <folder-to-encrypt>"
  exit 1
fi

FOLDER="$1"

# 🎯 Step 2: Check if folder exists
if [ ! -d "$FOLDER" ]; then
  echo "❌ Error: Folder not found — $FOLDER"
  exit 1
fi

# 📦 Setup names and paths
FOLDER_NAME=$(basename "$FOLDER")
TAR_NAME="$FOLDER_NAME.tar"
ENC_NAME="$TAR_NAME.enc"

# 🔐 Step 3: Prompt for password securely
echo "🔐 Please enter a password to encrypt '$FOLDER_NAME':"
read -s PASSWORD

echo "🔐 Confirm password:"
read -s PASSWORD_CONFIRM

# ❗ Step 4: Password match check
if [ "$PASSWORD" != "$PASSWORD_CONFIRM" ]; then
  echo "❌ Error: Passwords do not match. Exiting."
  exit 1
fi

# 📦 Step 5: Compress the folder into a tarball
echo "📦 Compressing folder '$FOLDER_NAME'..."
tar -cf "$TAR_NAME" -C "$(dirname "$FOLDER")" "$FOLDER_NAME"

# 🔒 Step 6: Encrypt the tarball using AES-256
echo "🔒 Encrypting tarball using AES-256..."
echo "$PASSWORD" | openssl enc -aes-256-cbc -pbkdf2 -salt -in "$TAR_NAME" -out "$ENC_NAME" -pass stdin

# 🧹 Step 7: Safely delete the original tarball
if [ -f "$TAR_NAME" ]; then
  echo "🧹 Deleting unencrypted tarball: $TAR_NAME"
  rm "$TAR_NAME"
else
  echo "⚠️ Warning: Could not find $TAR_NAME to delete"
fi

# ✅ Final success message
echo ""
echo "✅ Folder successfully encrypted!"
echo "📄 Output file: $ENC_NAME"
echo "🛡️  To decrypt, use:"
echo "    openssl enc -d -aes-256-cbc -pbkdf2 -in $ENC_NAME -out $TAR_NAME"
echo "    tar -xf $TAR_NAME"
