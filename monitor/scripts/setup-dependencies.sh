#!/bin/bash

# Dependency installation script
set -euo pipefail

echo "Installing system monitor dependencies..."

# Detect package manager
if command -v apt-get &> /dev/null; then
    # Debian/Ubuntu
    sudo apt-get update
    sudo apt-get install -y procps net-tools coreutils gawk
    
    # Optional dependencies
    echo "Installing optional dependencies..."
    sudo apt-get install -y libreoffice-calc gnuplot-nox
    
    # Install termgraph via pip if available
    if command -v pip3 &> /dev/null; then
        pip3 install --user termgraph csvkit
    fi
    
elif command -v yum &> /dev/null; then
    # RHEL/CentOS/Fedora
    sudo yum install -y procps-ng net-tools coreutils gawk
    
    # Optional dependencies
    sudo yum install -y libreoffice-calc gnuplot
    
    # Install termgraph via pip if available
    if command -v pip3 &> /dev/null; then
        pip3 install --user termgraph csvkit
    fi
    
elif command -v pacman &> /dev/null; then
    # Arch Linux
    sudo pacman -S --noconfirm procps-ng net-tools coreutils gawk
    
    # Optional dependencies
    sudo pacman -S --noconfirm libreoffice-fresh gnuplot
    
    # Install termgraph via pip if available
    if command -v pip3 &> /dev/null; then
        pip3 install --user termgraph csvkit
    fi
    
else
    echo "Unsupported package manager. Please install dependencies manually:"
    echo "  - procps (top, ps commands)"
    echo "  - net-tools (network statistics)"
    echo "  - coreutils (basic utilities)"
    echo "  - gawk (text processing)"
    echo "  - libreoffice-calc (optional)"
    echo "  - gnuplot (optional)"
    echo "  - termgraph (pip install termgraph)"
fi

echo "Dependencies installation complete!"