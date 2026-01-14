#!/bin/bash
# post_run_command.sh - Hook script for detecting terminal blocking events
# Called by Windsurf Cascade after each terminal command execution

set -euo pipefail

# Get script directory and source common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/common.sh"

# Load user preferences (hot-reload on each invocation)
load_preferences

# Patterns that indicate terminal is waiting for input
TERMINAL_INPUT_PATTERNS=(
    "Password:"
    "password:"
    "PASSWORD:"
    "passphrase"
    "Passphrase"
    "Enter passphrase"
    "sudo"
    "[sudo]"
    "Authentication required"
    "Permission denied"
    "Enter PIN"
    "Verification code"
)

# Detect if terminal output indicates waiting for input
# Args: $1 = command line, $2 = output (optional)
# Returns: 0 if blocking detected, 1 otherwise
detect_terminal_input() {
    local command_line="${1:-}"
    local output="${2:-}"
    
    # Check if command is likely to prompt for password
    if [[ "${command_line}" =~ ^sudo\  ]] || \
       [[ "${command_line}" =~ ssh\  ]] || \
       [[ "${command_line}" =~ git\ push ]] || \
       [[ "${command_line}" =~ git\ pull ]] || \
       [[ "${command_line}" =~ git\ fetch ]] || \
       [[ "${command_line}" =~ git\ clone ]] || \
       [[ "${command_line}" =~ docker\ login ]]; then
        return 0
    fi
    
    # Check output patterns
    for pattern in "${TERMINAL_INPUT_PATTERNS[@]}"; do
        if [[ "${output}" == *"${pattern}"* ]]; then
            return 0
        fi
    done
    
    return 1
}

# Main hook execution
main() {
    local input
    local command_line
    local event_type="terminal-input"
    
    # Read JSON input from stdin
    input=$(cat)
    
    # Extract command information
    command_line=$(echo "${input}" | parse_hook_input "tool_info.command_line")
    
    # Check if this might be a blocking command
    if detect_terminal_input "${command_line}" ""; then
        # Check if we should notify
        if should_notify "${event_type}"; then
            send_cascade_notification \
                "${event_type}" \
                "Cascade blocked: Terminal waiting for input" \
                "Command may require password or input: ${command_line:0:50}"
        fi
    fi
}

# Run main function
main "$@"
