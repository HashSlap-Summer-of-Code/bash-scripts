#!/bin/bash

# System Monitor Script
# Logs CPU, RAM, Disk usage, and network stats every 10 seconds
# Author: System Monitor
# Version: 1.0

set -euo pipefail

# Configuration
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly LOG_DIR="${SCRIPT_DIR}/logs"
readonly DATA_DIR="${SCRIPT_DIR}/data"
readonly OUTPUT_DIR="${SCRIPT_DIR}/output"
readonly CSV_FILE="${DATA_DIR}/system_stats_$(date +%Y%m%d_%H%M%S).csv"
readonly INTERVAL=10
readonly MAX_RECORDS=8640  # 24 hours worth of data (86400 seconds / 10 seconds)

# Colors for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m' # No Color

# Create directories if they don't exist
mkdir -p "$LOG_DIR" "$DATA_DIR" "$OUTPUT_DIR"

# Function to print colored output
print_status() {
    local color=$1
    local message=$2
    echo -e "${color}[$(date '+%Y-%m-%d %H:%M:%S')] ${message}${NC}"
}

# Function to check dependencies
check_dependencies() {
    local deps=("awk" "free" "df" "top" "ps" "cat" "grep")
    local missing=()
    
    for dep in "${deps[@]}"; do
        if ! command -v "$dep" &> /dev/null; then
            missing+=("$dep")
        fi
    done
    
    if [ ${#missing[@]} -ne 0 ]; then
        print_status "$RED" "Missing dependencies: ${missing[*]}"
        print_status "$YELLOW" "Please install missing tools and try again"
        exit 1
    fi
}

# Function to get CPU usage
get_cpu_usage() {
    # Get CPU usage using top command (1 iteration, batch mode)
    top -bn1 | grep "Cpu(s)" | awk '{print $2}' | sed 's/%us,//' | head -1
}

# Function to get memory usage
get_memory_usage() {
    local mem_info
    mem_info=$(free -m | grep '^Mem:')
    local total=$(echo "$mem_info" | awk '{print $2}')
    local used=$(echo "$mem_info" | awk '{print $3}')
    local percentage=$(awk "BEGIN {printf \"%.2f\", ($used/$total)*100}")
    echo "$percentage"
}

# Function to get disk usage
get_disk_usage() {
    df -h / | awk 'NR==2 {print $5}' | sed 's/%//'
}

# Function to get network statistics
get_network_stats() {
    local interface
    interface=$(ip route | grep default | awk '{print $5}' | head -1)
    
    if [ -z "$interface" ]; then
        echo "0,0"
        return
    fi
    
    local rx_bytes tx_bytes
    if [ -f "/sys/class/net/$interface/statistics/rx_bytes" ] && [ -f "/sys/class/net/$interface/statistics/tx_bytes" ]; then
        rx_bytes=$(cat "/sys/class/net/$interface/statistics/rx_bytes")
        tx_bytes=$(cat "/sys/class/net/$interface/statistics/tx_bytes")
        # Convert to KB
        rx_kb=$((rx_bytes / 1024))
        tx_kb=$((tx_bytes / 1024))
        echo "$rx_kb,$tx_kb"
    else
        echo "0,0"
    fi
}

# Function to get system load
get_system_load() {
    uptime | awk -F'load average:' '{print $2}' | awk '{print $1}' | sed 's/,//'
}

# Function to initialize CSV file
init_csv() {
    echo "timestamp,cpu_percent,memory_percent,disk_percent,network_rx_kb,network_tx_kb,system_load" > "$CSV_FILE"
    print_status "$GREEN" "CSV file initialized: $CSV_FILE"
}

# Function to log system stats
log_stats() {
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    local cpu_usage=$(get_cpu_usage)
    local memory_usage=$(get_memory_usage)
    local disk_usage=$(get_disk_usage)
    local network_stats=$(get_network_stats)
    local system_load=$(get_system_load)
    
    # Parse network stats
    local rx_kb=$(echo "$network_stats" | cut -d',' -f1)
    local tx_kb=$(echo "$network_stats" | cut -d',' -f2)
    
    # Write to CSV
    echo "$timestamp,$cpu_usage,$memory_usage,$disk_usage,$rx_kb,$tx_kb,$system_load" >> "$CSV_FILE"
    
    # Display current stats
    printf "\r${GREEN}CPU: %s%% | RAM: %s%% | Disk: %s%% | Net: %sKB↓ %sKB↑ | Load: %s${NC}" \
           "$cpu_usage" "$memory_usage" "$disk_usage" "$rx_kb" "$tx_kb" "$system_load"
}

# Function to generate HTML report
generate_html_report() {
    local html_file="${OUTPUT_DIR}/system_report_$(date +%Y%m%d_%H%M%S).html"
    
    cat > "$html_file" << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>System Monitor Report</title>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/Chart.js/3.9.1/chart.min.js"></script>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; background: #f5f5f5; }
        .container { max-width: 1200px; margin: 0 auto; background: white; padding: 20px; border-radius: 10px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }
        .header { text-align: center; color: #333; margin-bottom: 30px; }
        .chart-container { margin: 20px 0; height: 400px; }
        .stats-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 20px; margin: 20px 0; }
        .stat-card { background: #f8f9fa; padding: 15px; border-radius: 8px; text-align: center; }
        .stat-value { font-size: 2em; font-weight: bold; color: #007bff; }
        .stat-label { color: #666; margin-top: 5px; }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>System Monitor Report</h1>
            <p>Generated on: <span id="timestamp"></span></p>
        </div>
        
        <div class="stats-grid">
            <div class="stat-card">
                <div class="stat-value" id="avg-cpu">--</div>
                <div class="stat-label">Average CPU %</div>
            </div>
            <div class="stat-card">
                <div class="stat-value" id="avg-memory">--</div>
                <div class="stat-label">Average Memory %</div>
            </div>
            <div class="stat-card">
                <div class="stat-value" id="avg-disk">--</div>
                <div class="stat-label">Average Disk %</div>
            </div>
            <div class="stat-card">
                <div class="stat-value" id="avg-load">--</div>
                <div class="stat-label">Average Load</div>
            </div>
        </div>
        
        <div class="chart-container">
            <canvas id="systemChart"></canvas>
        </div>
    </div>

    <script>
        // This would be populated with actual CSV data
        document.getElementById('timestamp').textContent = new Date().toLocaleString();
        
        // Sample chart configuration
        const ctx = document.getElementById('systemChart').getContext('2d');
        const chart = new Chart(ctx, {
            type: 'line',
            data: {
                labels: [], // Will be populated with timestamps
                datasets: [{
                    label: 'CPU %',
                    data: [],
                    borderColor: 'rgb(255, 99, 132)',
                    tension: 0.1
                }, {
                    label: 'Memory %',
                    data: [],
                    borderColor: 'rgb(54, 162, 235)',
                    tension: 0.1
                }, {
                    label: 'Disk %',
                    data: [],
                    borderColor: 'rgb(255, 205, 86)',
                    tension: 0.1
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                scales: {
                    y: {
                        beginAtZero: true,
                        max: 100
                    }
                }
            }
        });
    </script>
</body>
</html>
EOF

    print_status "$GREEN" "HTML report generated: $html_file"
    echo "$html_file"
}

# Function to open CSV in LibreOffice
open_in_libreoffice() {
    if command -v libreoffice &> /dev/null; then
        print_status "$BLUE" "Opening CSV in LibreOffice..."
        libreoffice --calc "$CSV_FILE" &
    elif command -v localc &> /dev/null; then
        print_status "$BLUE" "Opening CSV in LibreOffice Calc..."
        localc "$CSV_FILE" &
    else
        print_status "$YELLOW" "LibreOffice not found. CSV file: $CSV_FILE"
    fi
}

# Function to generate terminal graph using termgraph
generate_terminal_graph() {
    if ! command -v termgraph &> /dev/null; then
        print_status "$YELLOW" "termgraph not installed. Install with: pip install termgraph"
        return
    fi
    
    print_status "$BLUE" "Generating terminal graphs..."
    
    # Create temporary files for different metrics
    local temp_cpu="${DATA_DIR}/temp_cpu.dat"
    local temp_memory="${DATA_DIR}/temp_memory.dat"
    local temp_disk="${DATA_DIR}/temp_disk.dat"
    
    # Extract data (skip header)
    tail -n +2 "$CSV_FILE" | awk -F',' '{print $2}' > "$temp_cpu"
    tail -n +2 "$CSV_FILE" | awk -F',' '{print $3}' > "$temp_memory"
    tail -n +2 "$CSV_FILE" | awk -F',' '{print $4}' > "$temp_disk"
    
    echo -e "\n${BLUE}CPU Usage Graph:${NC}"
    termgraph "$temp_cpu" --color blue --width 50 --format '{:.1f}%'
    
    echo -e "\n${BLUE}Memory Usage Graph:${NC}"
    termgraph "$temp_memory" --color green --width 50 --format '{:.1f}%'
    
    echo -e "\n${BLUE}Disk Usage Graph:${NC}"
    termgraph "$temp_disk" --color red --width 50 --format '{:.1f}%'
    
    # Cleanup temp files
    rm -f "$temp_cpu" "$temp_memory" "$temp_disk"
}

# Function to show usage
show_usage() {
    cat << EOF
Usage: $0 [OPTIONS]

Options:
    -h, --help          Show this help message
    -d, --duration N    Run for N seconds (default: continuous)
    -i, --interval N    Logging interval in seconds (default: 10)
    -o, --output FILE   Specify output CSV file
    --html              Generate HTML report after monitoring
    --libreoffice       Open CSV in LibreOffice after monitoring
    --termgraph         Show terminal graphs after monitoring
    --daemon            Run as daemon (background process)

Examples:
    $0                          # Run continuously
    $0 -d 300                   # Run for 5 minutes
    $0 -d 60 --html             # Run for 1 minute and generate HTML report
    $0 --libreoffice            # Run and open results in LibreOffice
    $0 --termgraph              # Run and show terminal graphs

EOF
}

# Function to handle cleanup on exit
cleanup() {
    print_status "$YELLOW" "\nStopping system monitor..."
    if [ -f "$CSV_FILE" ]; then
        local record_count=$(wc -l < "$CSV_FILE")
        print_status "$GREEN" "Logged $((record_count - 1)) records to: $CSV_FILE"
    fi
    exit 0
}

# Main monitoring loop
main_loop() {
    local duration=${1:-0}
    local start_time=$(date +%s)
    local record_count=0
    
    print_status "$GREEN" "Starting system monitoring (Ctrl+C to stop)..."
    print_status "$BLUE" "Logging to: $CSV_FILE"
    print_status "$BLUE" "Interval: ${INTERVAL} seconds"
    
    if [ "$duration" -gt 0 ]; then
        print_status "$BLUE" "Duration: ${duration} seconds"
    fi
    
    echo -e "\n"
    
    while true; do
        log_stats
        record_count=$((record_count + 1))
        
        # Check duration limit
        if [ "$duration" -gt 0 ]; then
            local current_time=$(date +%s)
            local elapsed=$((current_time - start_time))
            if [ "$elapsed" -ge "$duration" ]; then
                echo -e "\n"
                print_status "$GREEN" "Duration limit reached. Stopping..."
                break
            fi
        fi
        
        # Check max records limit
        if [ "$record_count" -ge "$MAX_RECORDS" ]; then
            echo -e "\n"
            print_status "$YELLOW" "Max records limit reached. Stopping..."
            break
        fi
        
        sleep "$INTERVAL"
    done
}

# Parse command line arguments
parse_args() {
    local duration=0
    local generate_html=false
    local open_libreoffice=false
    local show_termgraph=false
    local run_daemon=false
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_usage
                exit 0
                ;;
            -d|--duration)
                duration="$2"
                shift 2
                ;;
            -i|--interval)
                INTERVAL="$2"
                shift 2
                ;;
            -o|--output)
                CSV_FILE="$2"
                shift 2
                ;;
            --html)
                generate_html=true
                shift
                ;;
            --libreoffice)
                open_libreoffice=true
                shift
                ;;
            --termgraph)
                show_termgraph=true
                shift
                ;;
            --daemon)
                run_daemon=true
                shift
                ;;
            *)
                print_status "$RED" "Unknown option: $1"
                show_usage
                exit 1
                ;;
        esac
    done
    
    # Set up signal handlers
    trap cleanup SIGINT SIGTERM
    
    # Check dependencies
    check_dependencies
    
    # Initialize CSV file
    init_csv
    
    # Run monitoring
    if [ "$run_daemon" = true ]; then
        print_status "$BLUE" "Running as daemon..."
        main_loop "$duration" &
        echo $! > "${LOG_DIR}/monitor.pid"
        print_status "$GREEN" "Daemon started with PID: $(cat "${LOG_DIR}/monitor.pid")"
    else
        main_loop "$duration"
    fi
    
    # Post-processing
    if [ "$generate_html" = true ]; then
        generate_html_report
    fi
    
    if [ "$open_libreoffice" = true ]; then
        open_in_libreoffice
    fi
    
    if [ "$show_termgraph" = true ]; then
        generate_terminal_graph
    fi
}

# Script entry point
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    parse_args "$@"
fi