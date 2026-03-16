#!/usr/bin/env bash
set -u

RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
BOLD='\033[1m'
NC='\033[0m'

CPU_WARN=70
CPU_CRIT=90
RAM_WARN=75
RAM_CRIT=90
DISK_WARN=80
DISK_CRIT=95

print_status() {
  local label="$1"
  local value="$2"
  local threshold_warn="$3"
  local threshold_crit="$4"
  local unit="$5"

  local num_value
  num_value=$(echo "$value" | tr -d '%')

  local color="$GREEN"
  local status="OK"

  if [ "$(echo "$num_value >= $threshold_crit" | bc -l 2>/dev/null)" = "1" ]; then
    color="$RED"
    status="CRITICAL"
  elif [ "$(echo "$num_value >= $threshold_warn" | bc -l 2>/dev/null)" = "1" ]; then
    color="$YELLOW"
    status="WARNING"
  fi

  printf " %-14s %6s%-2s [%b%s%b]\n" "$label" "$value" "$unit" "$color" "$status" "$NC"
}

echo ""
echo -e "${BOLD}============================================${NC}"
echo -e "${BOLD} SERVER HEALTH CHECK REPORT${NC}"
echo -e "${BOLD}============================================${NC}"
echo " Host: $(hostname)"
echo " Date: $(date '+%Y-%m-%d %H:%M:%S')"
echo " OS: $(uname -s -r)"
echo -e "${BOLD}============================================${NC}"
echo ""

echo -e "${BOLD}[ CPU ]${NC}"
cpu_idle=$(top -bn1 | awk -F',' '/Cpu\(s\)|%Cpu/ {for(i=1;i<=NF;i++) if($i ~ / id/){gsub(/[^0-9.]/, "", $i); print $i; exit}}')
if [ -n "${cpu_idle:-}" ]; then
  cpu_used=$(echo "scale=1; 100 - $cpu_idle" | bc)
  print_status "CPU Usage" "$cpu_used" "$CPU_WARN" "$CPU_CRIT" "%"
else
  echo -e " CPU Usage: ${RED}Could not read${NC}"
fi

echo ""
echo -e "${BOLD}[ MEMORY ]${NC}"
mem_total=$(awk '/MemTotal/ {print $2}' /proc/meminfo)
mem_available=$(awk '/MemAvailable/ {print $2}' /proc/meminfo)
if [ -n "${mem_total:-}" ] && [ -n "${mem_available:-}" ]; then
  mem_used=$((mem_total - mem_available))
  mem_percent=$(echo "scale=1; $mem_used * 100 / $mem_total" | bc)
  mem_total_mb=$((mem_total / 1024))
  mem_used_mb=$((mem_used / 1024))
  print_status "RAM Usage" "$mem_percent" "$RAM_WARN" "$RAM_CRIT" "%"
  echo " Detail: ${mem_used_mb} MB used / ${mem_total_mb} MB total"
else
  echo -e " RAM Usage: ${RED}Could not read${NC}"
fi

echo ""
echo -e "${BOLD}[ DISK ]${NC}"
df -h --output=target,pcent,size,used,avail -x tmpfs -x devtmpfs -x squashfs 2>/dev/null | tail -n +2 | while read -r mount percent size used avail; do
  pct_num=$(echo "$percent" | tr -d '%')
  print_status "$mount" "$pct_num" "$DISK_WARN" "$DISK_CRIT" "%"
  echo " Size: $size | Used: $used | Free: $avail"
done

echo ""
echo -e "${BOLD}[ UPTIME ]${NC}"
uptime_str=$(uptime -p 2>/dev/null)
if [ -n "${uptime_str:-}" ]; then
  echo " $uptime_str"
else
  uptime
fi
load_avg=$(awk '{print $1, $2, $3}' /proc/loadavg)
echo " Load average: $load_avg"

echo ""
echo -e "${BOLD}============================================${NC}"
echo -e "${BOLD} CHECK COMPLETE${NC}"
echo -e "${BOLD}============================================${NC}"
echo ""

