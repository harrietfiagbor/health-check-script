#!/bin/bash

# Function to send alerts
send_alert() {
    # You can modify this function to send alerts through email, SMS, or any other means
    echo "ALERT: $1" >&2
}

# Function to check if a value exceeds the threshold
check_threshold() {
    local value=$1
    local threshold=$2
    if (( $(echo "$value > $threshold" | bc -l) )); then
        return 0  # Value exceeds threshold
    else
        return 1  # Value is within threshold
    fi
}

# Function to monitor CPU usage
monitor_cpu() {
    local cpu_usage=$(mpstat 1 1 | awk '$12 ~ /[0-9.]+/ { print 100 - $12 }' | tail -1)
    local cpu_threshold=$CPU_THRESHOLD
    echo "CPU Usage: $cpu_usage%"
    check_threshold "$cpu_usage" "$cpu_threshold" && send_alert "CPU usage exceeds threshold: $cpu_usage%"
}

# Function to monitor memory usage
monitor_memory() {
    local mem_usage=$(free | awk '/Mem/{print $3/$2 * 100.0}')
    local mem_threshold=$MEMORY_THRESHOLD
    echo "Memory Usage: $mem_usage%"
    check_threshold "$mem_usage" "$mem_threshold" && send_alert "Memory usage exceeds threshold: $mem_usage%"
}

# Function to monitor disk space
monitor_disk() {
    local disk_usage=$(df -h | awk '$NF=="/"{print $(NF-1)}' | sed 's/%//')
    local disk_threshold=$DISK_THRESHOLD
    echo "Disk Usage: $disk_usage%"
    check_threshold "$disk_usage" "$disk_threshold" && send_alert "Disk usage exceeds threshold: $disk_usage%"
}

# Function to monitor running processes
monitor_processes() {
    local process_count=$(ps -e --no-headers | wc -l)
    local process_threshold=$PROCESS_THRESHOLD
    echo "Running Processes: $process_count"
    check_threshold "$process_count" "$process_threshold" && send_alert "Number of running processes exceeds threshold: $process_count"
}

# Function to store historical data
store_historical_data() {
    # You can implement logic here to store historical data, e.g., in a log file or database
    echo "Historical data stored."
}

# Function to generate system health report
generate_report() {
    echo -e "\n\n------------------- System Health Report -------------------"
    monitor_cpu
    monitor_memory
    monitor_disk
    monitor_processes
    store_historical_data
}

# Load user configuration
source config.sh

# Run the script
generate_report
