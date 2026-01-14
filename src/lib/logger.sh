#!/bin/bash
# logger.sh - Notification event logging

# Log file path (set by common.sh)
: "${LOG_FILE:=${HOME}/.windsurf-notifier/notifications.log}"

# Log a notification event
# Args: $1 = event_type, $2 = status (SENT, SUPPRESSED, FAILED), $3 = message
log_event() {
    local event_type="$1"
    local status="$2"
    local message="$3"
    local timestamp
    local log_dir
    
    # Get ISO 8601 timestamp with timezone
    timestamp=$(date +"%Y-%m-%dT%H:%M:%S%z")
    
    # Ensure log directory exists
    log_dir=$(dirname "${LOG_FILE}")
    mkdir -p "${log_dir}"
    
    # Append to log file
    echo "${timestamp} | ${event_type} | ${status} | \"${message}\"" >> "${LOG_FILE}"
}

# Get recent log entries
# Args: $1 = number of lines (default: 10)
get_recent_logs() {
    local lines="${1:-10}"
    
    if [[ -f "${LOG_FILE}" ]]; then
        tail -n "${lines}" "${LOG_FILE}"
    fi
}

# Clear log file (for testing/maintenance)
clear_logs() {
    rm -f "${LOG_FILE}"
}
