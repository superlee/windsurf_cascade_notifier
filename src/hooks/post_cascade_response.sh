#!/bin/bash
# post_cascade_response.sh - Hook script for detecting task completion and approval events
# Called by Windsurf Cascade after each response

set -euo pipefail

# Get script directory and source common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/common.sh"

# Load user preferences (hot-reload on each invocation)
load_preferences

# Patterns that indicate task completion
COMPLETION_PATTERNS=(
    "completed"
    "done"
    "finished"
    "success"
)

# Patterns that indicate errors
ERROR_PATTERNS=(
    "error"
    "failed"
    "exception"
    "Error:"
    "FAILED"
)

# Patterns that indicate waiting for approval
APPROVAL_PATTERNS=(
    "waiting for approval"
    "requires approval"
    "approve"
    "confirm"
    "permission"
)

# Detect task completion from response
# Args: $1 = response content
# Returns: 0 if completion detected, 1 otherwise
detect_task_completion() {
    local response="${1:-}"
    
    # Simple heuristic: if we get a response, task likely completed
    # In real implementation, Cascade provides explicit completion signals
    if [[ -n "${response}" ]]; then
        return 0
    fi
    
    return 1
}

# Detect error state from response
# Args: $1 = response content
# Returns: 0 if error detected, 1 otherwise
detect_task_error() {
    local response="${1:-}"
    
    for pattern in "${ERROR_PATTERNS[@]}"; do
        if [[ "${response}" == *"${pattern}"* ]]; then
            return 0
        fi
    done
    
    return 1
}

# Detect approval waiting state
# Args: $1 = response content
# Returns: 0 if approval waiting detected, 1 otherwise
detect_approval_waiting() {
    local response="${1:-}"
    
    for pattern in "${APPROVAL_PATTERNS[@]}"; do
        if [[ "${response}" == *"${pattern}"* ]]; then
            return 0
        fi
    done
    
    return 1
}

# Main hook execution
main() {
    local input
    local response
    local trajectory_id
    
    # Read JSON input from stdin
    input=$(cat)
    
    # Extract response information
    response=$(echo "${input}" | parse_hook_input "tool_info.response" 2>/dev/null || echo "")
    trajectory_id=$(echo "${input}" | parse_hook_input "trajectory_id" 2>/dev/null || echo "unknown")
    
    # Check for approval waiting (US3 - Priority P3)
    if detect_approval_waiting "${response}"; then
        if should_notify "approval-required"; then
            send_cascade_notification \
                "approval-required" \
                "Cascade: Waiting for your approval" \
                "Cascade needs your approval to proceed"
        fi
        return
    fi
    
    # Check for error (US2 - Priority P2)
    if detect_task_error "${response}"; then
        if should_notify "task-error"; then
            send_cascade_notification \
                "task-error" \
                "Cascade: Task stopped - Error encountered" \
                "An error occurred during task execution"
        fi
        return
    fi
    
    # Default: task completed (US2 - Priority P2)
    if detect_task_completion "${response}"; then
        if should_notify "task-complete"; then
            send_cascade_notification \
                "task-complete" \
                "Cascade: Task completed" \
                "Cascade has finished the current task"
        fi
    fi
}

# Run main function
main "$@"
