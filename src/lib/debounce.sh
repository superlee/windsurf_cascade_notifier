#!/bin/bash
# debounce.sh - Notification debouncing to prevent spam

# Debounce directory (set by common.sh)
: "${DEBOUNCE_DIR:=${HOME}/.windsurf-notifier/debounce}"

# Check if enough time has passed since last notification of this type
# Args: $1 = event_type, $2 = debounce_seconds
# Returns: 0 if can notify, 1 if within debounce window
check_debounce() {
    local event_type="$1"
    local debounce_seconds="${2:-5}"
    local debounce_file="${DEBOUNCE_DIR}/${event_type}"
    local last_time
    local current_time
    local elapsed
    
    # Ensure debounce directory exists
    mkdir -p "${DEBOUNCE_DIR}"
    
    # Get current timestamp
    current_time=$(date +%s)
    
    # Check if debounce file exists
    if [[ -f "${debounce_file}" ]]; then
        last_time=$(cat "${debounce_file}" 2>/dev/null || echo 0)
        elapsed=$((current_time - last_time))
        
        if [[ ${elapsed} -lt ${debounce_seconds} ]]; then
            # Within debounce window
            return 1
        fi
    fi
    
    # Outside debounce window (or first notification)
    return 0
}

# Update the debounce timestamp for an event type
# Args: $1 = event_type
update_debounce() {
    local event_type="$1"
    local debounce_file="${DEBOUNCE_DIR}/${event_type}"
    
    # Ensure debounce directory exists
    mkdir -p "${DEBOUNCE_DIR}"
    
    # Write current timestamp
    date +%s > "${debounce_file}"
}

# Clear debounce for an event type (for testing)
# Args: $1 = event_type
clear_debounce() {
    local event_type="$1"
    local debounce_file="${DEBOUNCE_DIR}/${event_type}"
    
    rm -f "${debounce_file}"
}
