#!/bin/bash
# hooks_manager.sh - Shared functions for Windsurf hooks.json management
# Used by install.sh and uninstall.sh

set -euo pipefail

# Configuration
WINDSURF_HOOKS_DIR="${HOME}/.codeium/windsurf"
WINDSURF_HOOKS_FILE="${WINDSURF_HOOKS_DIR}/hooks.json"
NOTIFIER_INSTALL_DIR="${HOME}/.windsurf-notifier"

# Pattern to identify notifier hooks
NOTIFIER_PATH_PATTERN="${NOTIFIER_INSTALL_DIR}"

# Backup hooks.json before modification
# Args: none
# Returns: 0 on success, 1 on failure
backup_hooks_json() {
    if [[ -f "${WINDSURF_HOOKS_FILE}" ]]; then
        local backup_file="${WINDSURF_HOOKS_FILE}.backup.$(date +%Y%m%d_%H%M%S)"
        cp "${WINDSURF_HOOKS_FILE}" "${backup_file}"
        echo "Backup created: ${backup_file}"
        return 0
    fi
    return 0
}

# Merge notifier hooks into existing hooks.json
# Args: none
# Returns: 0 on success, 1 on failure
merge_hooks() {
    local post_run_hook="bash ${NOTIFIER_INSTALL_DIR}/hooks/post_run_command.sh"
    local post_response_hook="bash ${NOTIFIER_INSTALL_DIR}/hooks/post_cascade_response.sh"
    
    # Create directory if needed
    mkdir -p "${WINDSURF_HOOKS_DIR}"
    
    # If hooks.json doesn't exist, create it fresh
    if [[ ! -f "${WINDSURF_HOOKS_FILE}" ]]; then
        cat > "${WINDSURF_HOOKS_FILE}" << EOF
{
  "hooks": {
    "post_run_command": [
      {
        "command": "${post_run_hook}",
        "show_output": false
      }
    ],
    "post_cascade_response": [
      {
        "command": "${post_response_hook}",
        "show_output": false
      }
    ]
  }
}
EOF
        echo "Created new hooks.json with notifier hooks"
        return 0
    fi
    
    # Check if jq is available
    if ! command -v jq &> /dev/null; then
        echo "ERROR: jq is required for JSON manipulation. Install with: brew install jq"
        return 1
    fi
    
    # Remove existing notifier hooks first (for idempotency), then add fresh ones
    local temp_file=$(mktemp)
    
    # First, filter out any existing notifier hooks
    jq --arg pattern "${NOTIFIER_PATH_PATTERN}" '
        .hooks.post_run_command = (.hooks.post_run_command // [] | map(select(.command | contains($pattern) | not))) |
        .hooks.post_cascade_response = (.hooks.post_cascade_response // [] | map(select(.command | contains($pattern) | not)))
    ' "${WINDSURF_HOOKS_FILE}" > "${temp_file}"
    
    # Then add fresh notifier hooks
    jq --arg post_run "${post_run_hook}" --arg post_response "${post_response_hook}" '
        .hooks.post_run_command = (.hooks.post_run_command + [{"command": $post_run, "show_output": false}]) |
        .hooks.post_cascade_response = (.hooks.post_cascade_response + [{"command": $post_response, "show_output": false}])
    ' "${temp_file}" > "${WINDSURF_HOOKS_FILE}"
    
    rm -f "${temp_file}"
    echo "Merged notifier hooks into existing hooks.json"
    return 0
}

# Remove notifier hooks from hooks.json
# Args: none
# Returns: 0 on success, 1 on failure
remove_notifier_hooks() {
    # If hooks.json doesn't exist, nothing to do
    if [[ ! -f "${WINDSURF_HOOKS_FILE}" ]]; then
        echo "No hooks.json found - nothing to remove"
        return 0
    fi
    
    # Check if jq is available
    if ! command -v jq &> /dev/null; then
        echo "ERROR: jq is required for JSON manipulation. Install with: brew install jq"
        return 1
    fi
    
    # Filter out notifier hooks
    local temp_file=$(mktemp)
    
    jq --arg pattern "${NOTIFIER_PATH_PATTERN}" '
        .hooks.post_run_command = (.hooks.post_run_command // [] | map(select(.command | contains($pattern) | not))) |
        .hooks.post_cascade_response = (.hooks.post_cascade_response // [] | map(select(.command | contains($pattern) | not)))
    ' "${WINDSURF_HOOKS_FILE}" > "${temp_file}"
    
    mv "${temp_file}" "${WINDSURF_HOOKS_FILE}"
    echo "Removed notifier hooks from hooks.json"
    return 0
}

# Check if project-level hooks.json exists in current directory
# Args: none
# Returns: 0 if exists, 1 if not
check_project_level_hooks() {
    if [[ -f ".windsurf/hooks.json" ]]; then
        return 0
    fi
    return 1
}

# Validate JSON file is well-formed
# Args: $1 = file path
# Returns: 0 if valid JSON, 1 if invalid
validate_hooks_json() {
    local file="${1:-${WINDSURF_HOOKS_FILE}}"
    
    if [[ ! -f "${file}" ]]; then
        return 0  # Non-existent is OK (will be created)
    fi
    
    if ! command -v jq &> /dev/null; then
        echo "Warning: jq not available, skipping JSON validation"
        return 0
    fi
    
    if jq empty "${file}" 2>/dev/null; then
        return 0
    else
        echo "ERROR: ${file} contains malformed JSON"
        return 1
    fi
}

# Check write permissions for hooks file
# Args: none
# Returns: 0 if writable, 1 if not
check_hooks_permissions() {
    # Check directory
    if [[ -d "${WINDSURF_HOOKS_DIR}" ]]; then
        if [[ ! -w "${WINDSURF_HOOKS_DIR}" ]]; then
            echo "ERROR: No write permission for directory: ${WINDSURF_HOOKS_DIR}"
            return 1
        fi
    fi
    
    # Check file if exists
    if [[ -f "${WINDSURF_HOOKS_FILE}" ]]; then
        if [[ ! -w "${WINDSURF_HOOKS_FILE}" ]]; then
            echo "ERROR: No write permission for file: ${WINDSURF_HOOKS_FILE}"
            return 1
        fi
    fi
    
    return 0
}
