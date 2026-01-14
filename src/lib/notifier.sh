#!/bin/bash
# notifier.sh - Core notification functions

# Send a desktop notification using macOS native osascript
# Args: $1 = title, $2 = body, $3 = sound (optional, default: true)
# Returns: 0 on success, 1 on failure
send_notification() {
    local title="$1"
    local body="$2"
    local sound="${3:-true}"
    
    # Escape quotes in title and body for AppleScript
    title="${title//\"/\\\"}"
    body="${body//\"/\\\"}"
    
    # Build AppleScript command
    local script="display notification \"${body}\" with title \"${title}\""
    
    # Add sound if enabled
    if [[ "${sound}" == "true" ]]; then
        script="${script} sound name \"default\""
    fi
    
    # Execute notification
    if osascript -e "${script}" 2>/dev/null; then
        return 0
    else
        return 1
    fi
}

# Send notification with full lifecycle handling
# Args: $1 = event_type, $2 = title, $3 = body
# Returns: 0 on success, 1 if suppressed or failed
send_cascade_notification() {
    local event_type="$1"
    local title="$2"
    local body="$3"
    
    # Send the notification
    if send_notification "${title}" "${body}" "${PREF_SOUND_ENABLED:-true}"; then
        # Log success
        log_event "${event_type}" "SENT" "${title}"
        
        # Update debounce timestamp
        update_debounce "${event_type}"
        
        return 0
    else
        log_event "${event_type}" "FAILED" "osascript error"
        return 1
    fi
}
