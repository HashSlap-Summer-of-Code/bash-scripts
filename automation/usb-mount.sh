#!/bin/bash

# ============================================================
# 🔧 USB Auto-Mounter Script
# Detects all connected USB drives (removable partitions)
# Mounts them to /mnt/usb-<label or uuid>
# ============================================================

set -euo pipefail

echo "🔍 Scanning for USB drives..."

# Get list of removable partitions (RM=1, TYPE=part)
usb_partitions=$(lsblk -rpno NAME,RM,TYPE | awk '$2=="1" && $3=="part" {print $1}')

if [[ -z "$usb_partitions" ]]; then
    echo "❌ No USB partitions detected."
    exit 0
fi

for device in $usb_partitions; do
    echo -e "\n📦 Found device: $device"

    # Use blkid to get label and UUID
    label=$(blkid -o value -s LABEL "$device" 2>/dev/null || true)
    uuid=$(blkid -o value -s UUID "$device" 2>/dev/null || true)

    # Fallback if label is missing
    if [[ -z "$label" && -n "$uuid" ]]; then
        label="usb-$uuid"
        echo "⚠️ No label found — using UUID: $label"
    elif [[ -z "$label" && -z "$uuid" ]]; then
        echo "❌ Skipping $device — no label or UUID found."
        continue
    fi

    # Sanitize label for folder names
    safe_label=$(echo "$label" | tr -cd '[:alnum:]_-')
    mount_point="/mnt/usb-$safe_label"

    # Create mount point if it doesn't exist
    if [[ ! -d "$mount_point" ]]; then
        echo "📂 Creating mount point: $mount_point"
        sudo mkdir -p "$mount_point"
    fi

    # Check if device is already mounted
    if mount | grep -q "$mount_point"; then
        echo "✅ Already mounted at $mount_point — skipping."
        continue
    fi

    # Mount the device
    echo "🔗 Mounting $device to $mount_point..."
    if sudo mount "$device" "$mount_point"; then
        echo "✅ Successfully mounted $device at $mount_point"
    else
        echo "❌ Failed to mount $device"
    fi
done

echo -e "\n🎉 All USB drives processed.\n"
