#!/bin/bash

# ============================================================
# Script Name : net-diagnose.sh
# Description : Smart, interactive network troubleshooting tool
#               for checking connectivity, DNS, gateway, and IP.
# Tools Used  : ping, dig, ip, awk, hostname, curl
# ============================================================

echo "🌐 Network Troubleshooting Script"
echo "================================="
echo "📅 Started at: $(date)"
echo

# ------------------------------------------------------------
# Step 1: Ping 3 known, reliable hosts to check basic reachability
# ------------------------------------------------------------
echo "🔍 Step 1: Pinging Known Hosts..."
hosts=("8.8.8.8" "1.1.1.1" "github.com")
failures=0
ping_failures=0

for host in "${hosts[@]}"; do
  echo -n "➡️  Checking $host... "
  if ping -c 2 "$host" &> /dev/null; then
    echo "✅ Reachable"
  else
    echo "❌ Not reachable"
    ((failures++))
    ((ping_failures++))
  fi
done

# ------------------------------------------------------------
# Step 2: DNS Resolution Test (openai.com)
# ------------------------------------------------------------
echo -e "\n🧠 Step 2: DNS Resolution Test (openai.com)..."
dns_result=$(dig +short openai.com)

if [[ -n "$dns_result" ]]; then
  echo "✅ DNS is working:"
  echo "$dns_result" | while read ip; do
    echo "   - $ip"
  done
else
  echo "❌ DNS resolution failed for openai.com"
  ((failures++))
fi

# ------------------------------------------------------------
# Step 3: Gateway & IP Check
# ------------------------------------------------------------
echo -e "\n📡 Step 3: Checking Local IP and Gateway..."
gateway=$(ip route | awk '/default/ {print $3}')
ipaddr=$(hostname -I | awk '{print $1}')

echo "🌐 IP Address : ${ipaddr:-Not Found}"
echo "🚪 Gateway    : ${gateway:-Not Found}"

# ------------------------------------------------------------
# Step 4: Internet Connectivity Test via HTTPS
# ------------------------------------------------------------
echo -e "\n🌍 Step 4: Checking Internet Access (https://example.com)..."
status=$(curl -s -o /dev/null -w "%{http_code}" https://example.com)

if [ "$status" = "200" ]; then
  echo "✅ Internet access confirmed (HTTP 200 OK)"
else
  echo "❌ Web access failed — HTTP status: $status"
  ((failures++))
fi

# ------------------------------------------------------------
# Step 5: Diagnosis Summary and Smart Suggestions
# ------------------------------------------------------------
echo -e "\n🩺 Final Diagnosis"
echo "---------------------"

if [ "$failures" -eq 0 ]; then
  echo "🎉 All systems are operational. You're online!"
else
  echo "⚠️  Detected $failures issue(s)."
  echo -e "\n🔧 Suggestions:"

  # Suggest based on specific failures
  [[ -z "$ipaddr" ]] && echo "• No IP address assigned. Try reconnecting to Wi-Fi or checking your adapter."
  [[ -z "$gateway" ]] && echo "• No default gateway found. Check your router or network settings."
  [[ -z "$dns_result" ]] && echo "• DNS failed. Try switching to 8.8.8.8 (Google) or 1.1.1.1 (Cloudflare)."
  [[ "$status" != "200" ]] && echo "• Unable to access websites. Try visiting another site or check proxy/VPN/firewall settings."
  [ "$ping_failures" -ge 1 ] && echo "• Ping failures detected. Some hosts may be unreachable or blocked (e.g., ICMP disabled)."
  [ "$failures" -ge 3 ] && echo "• Multiple failures. Restart your router or contact your internet provider."
fi

# ------------------------------------------------------------
# Optional: Ask to save report
# ------------------------------------------------------------
echo -e "\n📄 Do you want to save this report to a file? (y/n)"
read -r save_choice

if [[ "$save_choice" == "y" || "$save_choice" == "Y" ]]; then
  report_file="net-diagnose-report-$(date +%Y%m%d_%H%M%S).txt"
  {
    echo "Network Troubleshooting Report"
    echo "Generated at: $(date)"
    echo "------------------------------------"
    echo "Ping failures: $ping_failures"
    echo "DNS result: $dns_result"
    echo "IP Address: $ipaddr"
    echo "Gateway: $gateway"
    echo "Curl Status: $status"
  } > "$report_file"
  echo "✅ Report saved to: $report_file"
fi
