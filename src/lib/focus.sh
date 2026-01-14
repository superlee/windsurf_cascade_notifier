#!/bin/bash
# focus.sh - Window focus detection functions

# Check if Windsurf is the frontmost (focused) application
# Returns: 0 if Windsurf is focused, 1 otherwise
is_windsurf_focused() {
    local frontmost
    
    # Use AppleScript to get the frontmost application name
    frontmost=$(osascript -e 'tell application "System Events" to get name of first application process whose frontmost is true' 2>/dev/null)
    
    # Check if it's Windsurf (case-insensitive)
    frontmost_lower=$(echo "${frontmost}" | tr '[:upper:]' '[:lower:]')
    if [[ "${frontmost_lower}" == "windsurf" ]]; then
        return 0
    fi
    
    return 1
}

# Activate Windsurf (bring to focus)
# Used when user clicks notification
activate_windsurf() {
    osascript -e 'tell application "Windsurf" to activate' 2>/dev/null || true
}
