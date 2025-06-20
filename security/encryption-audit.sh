#!/bin/bash

# -----------------------------------------------------------------------------
# Script Name : encryption-audit.sh
# Description : Audit system partitions for encryption (LUKS, eCryptfs, etc.)
#               Reports mount points and encryption status.
#               Suggests encryption measures if not detected.
#
# Usage       : sudo ./encryption-audit.sh | tee encryption-audit-report.txt
#
# Dependencies: lsblk, cryptsetup, blkid, mount, awk, grep, tee
# -----------------------------------------------------------------------------

echo "🔐 Disk Encryption Audit Report"
echo "Generated on: $(date)"
echo "========================================"
echo ""

# Function to check if a device is encrypted (LUKS/eCryptfs)
check_encryption_status() {
    local dev="$1"

    # Check for LUKS encryption
    if cryptsetup isLuks "$dev" &>/dev/null; then
        echo "LUKS-encrypted"
        return
    fi

    # Check for eCryptfs
    if blkid "$dev" 2>/dev/null | grep -qi 'ecryptfs'; then
        echo "eCryptfs-encrypted"
        return
    fi

    echo "❌ Not Encrypted"
}

# List all block devices and loop over them
lsblk -o NAME,TYPE,MOUNTPOINT -r | grep -w 'part' | while read -r name type mountpoint; do
    dev="/dev/$name"

    # Skip devices with no mountpoint
    if [[ -z "$mountpoint" ]]; then
        continue
    fi

    # Check if device exists
    if [[ ! -b "$dev" ]]; then
        continue
    fi

    status=$(check_encryption_status "$dev")
    echo "🔍 Device: $dev"
    echo "    Mountpoint : $mountpoint"
    echo "    Encryption : $status"
    echo "----------------------------------------"
done

# Summary recommendation
if ! lsblk -o NAME | grep -q "^crypt"; then
    echo ""
    echo "⚠️  No encrypted devices detected (LUKS/eCryptfs)."
    echo "🔧 Suggestion: Consider enabling full-disk encryption or encrypt sensitive partitions (e.g., /home, /data)"
    echo "🔒 Tools: cryptsetup (LUKS), eCryptfs, LVM + LUKS"
else
    echo ""
    echo "✅ At least one encrypted volume detected."
fi
