#!/bin/bash

# System Monitor Installation Script
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALL_DIR="/opt/system-monitor"
SERVICE_FILE="/etc/systemd/system/system-monitor.service"

echo "Installing System Monitor..."

# Create installation directory
sudo mkdir -p "$INSTALL_DIR"

# Copy files
sudo cp "$SCRIPT_DIR/system-logger.sh" "$INSTALL_DIR/"
sudo cp -r "$SCRIPT_DIR/config" "$INSTALL_DIR/"
sudo cp -r "$SCRIPT_DIR/scripts" "$INSTALL_DIR/"

# Make scripts executable
sudo chmod +x "$INSTALL_DIR/system-logger.sh"
sudo chmod +x "$INSTALL_DIR/scripts/"*.sh

# Install systemd service
sudo cp "$SCRIPT_DIR/config/systemd/system-monitor.service" "$SERVICE_FILE"
sudo systemctl daemon-reload

echo "Installation complete!"
echo "Usage:"
echo "  Start service: sudo systemctl start system-monitor"
echo "  Enable on boot: sudo systemctl enable system-monitor"
echo "  View logs: journalctl -u system-monitor -f"