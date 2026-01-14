#!/bin/bash
# common.sh - Shared functions for Cascade notification hooks
# This file is sourced by hook scripts

set -euo pipefail

# Configuration
NOTIFIER_DIR="${HOME}/.windsurf-notifier"
CONFIG_FILE="${NOTIFIER_DIR}/config.json"
LOG_FILE="${NOTIFIER_DIR}/notifications.log"
DEBOUNCE_DIR="${NOTIFIER_DIR}/debounce"

# Source library functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="${SCRIPT_DIR}/../lib"

source "${LIB_DIR}/json_parser.sh"
source "${LIB_DIR}/focus.sh"
source "${LIB_DIR}/notifier.sh"
source "${LIB_DIR}/debounce.sh"
source "${LIB_DIR}/logger.sh"

# Ensure directories exist
ensure_dirs() {
    mkdir -p "${NOTIFIER_DIR}"
    mkdir -p "${DEBOUNCE_DIR}"
}

# Load user preferences from config file
# Returns: Sets global preference variables
load_preferences() {
    local config
    
    # Use default config if user config doesn't exist
    if [[ -f "${CONFIG_FILE}" ]]; then
        config="${CONFIG_FILE}"
    else
        config="${SCRIPT_DIR}/../config/default-config.json"
    fi
    
    # Parse config values
    PREF_ENABLED=$(parse_json_value "${config}" "enabled" "true")
    PREF_TERMINAL_INPUT=$(parse_json_value "${config}" "terminal_input" "true")
    PREF_GIT_COMMANDS=$(parse_json_value "${config}" "git_commands" "false")
    PREF_TASK_COMPLETE=$(parse_json_value "${config}" "task_complete" "true")
    PREF_TASK_ERROR=$(parse_json_value "${config}" "task_error" "true")
    PREF_APPROVAL_REQUIRED=$(parse_json_value "${config}" "approval_required" "true")
    PREF_SOUND_ENABLED=$(parse_json_value "${config}" "sound_enabled" "true")
    PREF_DEBOUNCE_SECONDS=$(parse_json_value "${config}" "debounce_seconds" "5")
    
    export PREF_ENABLED PREF_TERMINAL_INPUT PREF_GIT_COMMANDS PREF_TASK_COMPLETE
    export PREF_TASK_ERROR PREF_APPROVAL_REQUIRED PREF_SOUND_ENABLED
    export PREF_DEBOUNCE_SECONDS
}

# Check if notification should be sent for given event type
# Args: $1 = event_type (terminal-input, task-complete, task-error, approval-required)
# Returns: 0 if should notify, 1 if should skip
should_notify() {
    local event_type="$1"
    
    # Check master switch
    if [[ "${PREF_ENABLED}" != "true" ]]; then
        return 1
    fi
    
    # Check event-specific preference
    case "${event_type}" in
        terminal-input)
            [[ "${PREF_TERMINAL_INPUT}" == "true" ]] || return 1
            ;;
        task-complete)
            [[ "${PREF_TASK_COMPLETE}" == "true" ]] || return 1
            ;;
        task-error)
            [[ "${PREF_TASK_ERROR}" == "true" ]] || return 1
            ;;
        approval-required)
            [[ "${PREF_APPROVAL_REQUIRED}" == "true" ]] || return 1
            ;;
        *)
            return 1
            ;;
    esac
    
    # Check if Windsurf is focused
    if is_windsurf_focused; then
        log_event "${event_type}" "SUPPRESSED" "windsurf-focused"
        return 1
    fi
    
    # Check debounce
    if ! check_debounce "${event_type}" "${PREF_DEBOUNCE_SECONDS}"; then
        log_event "${event_type}" "SUPPRESSED" "debounced"
        return 1
    fi
    
    return 0
}

# Initialize on source
ensure_dirs
