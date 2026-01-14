#!/usr/bin/env bats
# test_hooks_manager.bats - Tests for hooks.json management functions

setup() {
    # Source the hooks manager
    SCRIPT_DIR="$(cd "$(dirname "$BATS_TEST_FILENAME")/../../src/lib" && pwd)"
    
    # Create temp directory for testing
    export TEST_HOME="$(mktemp -d)"
    export HOME="${TEST_HOME}"
    export WINDSURF_HOOKS_DIR="${HOME}/.codeium/windsurf"
    export WINDSURF_HOOKS_FILE="${WINDSURF_HOOKS_DIR}/hooks.json"
    export NOTIFIER_INSTALL_DIR="${HOME}/.windsurf-notifier"
    
    # Create notifier install dir (simulating installed state)
    mkdir -p "${NOTIFIER_INSTALL_DIR}/hooks"
    
    # Source the hooks manager with our test HOME
    source "${SCRIPT_DIR}/hooks_manager.sh"
}

teardown() {
    # Cleanup temp directory
    rm -rf "${TEST_HOME}"
}

# ============================================================================
# User Story 1: Auto-configure User-Level Hooks on Install
# ============================================================================

@test "US1: Fresh install creates hooks.json when none exists" {
    # Ensure no hooks.json exists
    [ ! -f "${WINDSURF_HOOKS_FILE}" ]
    
    # Run merge_hooks
    run merge_hooks
    [ "$status" -eq 0 ]
    
    # Verify hooks.json was created
    [ -f "${WINDSURF_HOOKS_FILE}" ]
    
    # Verify it contains notifier hooks
    if command -v jq &> /dev/null; then
        local count=$(jq '.hooks.post_run_command | map(select(.command | contains("windsurf-notifier"))) | length' "${WINDSURF_HOOKS_FILE}")
        [ "$count" -eq 1 ]
    fi
}

@test "US1: Install with existing hooks preserves them" {
    # Create existing hooks.json with other hooks
    mkdir -p "${WINDSURF_HOOKS_DIR}"
    cat > "${WINDSURF_HOOKS_FILE}" << 'EOF'
{
  "hooks": {
    "post_run_command": [
      {"command": "bash /some/other/hook.sh", "show_output": false}
    ],
    "post_cascade_response": []
  }
}
EOF
    
    # Run merge_hooks
    run merge_hooks
    [ "$status" -eq 0 ]
    
    # Verify both hooks exist
    if command -v jq &> /dev/null; then
        local total=$(jq '.hooks.post_run_command | length' "${WINDSURF_HOOKS_FILE}")
        [ "$total" -eq 2 ]
        
        # Verify original hook preserved
        local other=$(jq '.hooks.post_run_command | map(select(.command | contains("other/hook"))) | length' "${WINDSURF_HOOKS_FILE}")
        [ "$other" -eq 1 ]
    fi
}

@test "US1: Idempotent install - no duplicates on re-run" {
    # Run merge_hooks twice
    run merge_hooks
    [ "$status" -eq 0 ]
    
    run merge_hooks
    [ "$status" -eq 0 ]
    
    # Verify only one notifier hook exists
    if command -v jq &> /dev/null; then
        local count=$(jq '.hooks.post_run_command | map(select(.command | contains("windsurf-notifier"))) | length' "${WINDSURF_HOOKS_FILE}")
        [ "$count" -eq 1 ]
    fi
}

@test "US1: Parent directories created if missing" {
    # Ensure directory doesn't exist
    [ ! -d "${WINDSURF_HOOKS_DIR}" ]
    
    # Run merge_hooks
    run merge_hooks
    [ "$status" -eq 0 ]
    
    # Verify directory was created
    [ -d "${WINDSURF_HOOKS_DIR}" ]
}

@test "US1: Backup created before modification" {
    # Create existing hooks.json
    mkdir -p "${WINDSURF_HOOKS_DIR}"
    echo '{"hooks":{}}' > "${WINDSURF_HOOKS_FILE}"
    
    # Run backup
    run backup_hooks_json
    [ "$status" -eq 0 ]
    
    # Verify backup file exists
    local backup_count=$(ls -1 "${WINDSURF_HOOKS_DIR}"/hooks.json.backup.* 2>/dev/null | wc -l)
    [ "$backup_count" -ge 1 ]
}

# ============================================================================
# User Story 2: Clean Uninstall of Hooks
# ============================================================================

@test "US2: Uninstall removes notifier hooks" {
    # First install hooks
    run merge_hooks
    [ "$status" -eq 0 ]
    
    # Then remove them
    run remove_notifier_hooks
    [ "$status" -eq 0 ]
    
    # Verify notifier hooks are gone
    if command -v jq &> /dev/null; then
        local count=$(jq '.hooks.post_run_command | map(select(.command | contains("windsurf-notifier"))) | length' "${WINDSURF_HOOKS_FILE}")
        [ "$count" -eq 0 ]
    fi
}

@test "US2: Uninstall preserves other hooks" {
    # Create hooks.json with both notifier and other hooks
    mkdir -p "${WINDSURF_HOOKS_DIR}"
    cat > "${WINDSURF_HOOKS_FILE}" << EOF
{
  "hooks": {
    "post_run_command": [
      {"command": "bash /some/other/hook.sh", "show_output": false},
      {"command": "bash ${NOTIFIER_INSTALL_DIR}/hooks/post_run_command.sh", "show_output": false}
    ],
    "post_cascade_response": []
  }
}
EOF
    
    # Remove notifier hooks
    run remove_notifier_hooks
    [ "$status" -eq 0 ]
    
    # Verify other hook preserved
    if command -v jq &> /dev/null; then
        local other=$(jq '.hooks.post_run_command | map(select(.command | contains("other/hook"))) | length' "${WINDSURF_HOOKS_FILE}")
        [ "$other" -eq 1 ]
        
        local notifier=$(jq '.hooks.post_run_command | map(select(.command | contains("windsurf-notifier"))) | length' "${WINDSURF_HOOKS_FILE}")
        [ "$notifier" -eq 0 ]
    fi
}

@test "US2: Uninstall handles missing hooks.json gracefully" {
    # Ensure no hooks.json exists
    [ ! -f "${WINDSURF_HOOKS_FILE}" ]
    
    # Run remove - should not error
    run remove_notifier_hooks
    [ "$status" -eq 0 ]
}

# ============================================================================
# Edge Cases
# ============================================================================

@test "Edge: check_project_level_hooks detects .windsurf/hooks.json" {
    # Create project-level hooks
    mkdir -p ".windsurf"
    echo '{}' > ".windsurf/hooks.json"
    
    run check_project_level_hooks
    [ "$status" -eq 0 ]
    
    # Cleanup
    rm -rf ".windsurf"
}

@test "Edge: check_project_level_hooks returns 1 when not present" {
    run check_project_level_hooks
    [ "$status" -eq 1 ]
}
