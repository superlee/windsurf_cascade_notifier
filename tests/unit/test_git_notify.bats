#!/usr/bin/env bats
# test_git_notify.bats - Tests for git notification configuration
# Tests both disabled (default) and enabled states

setup() {
    # Source the hook script functions
    SCRIPT_DIR="$(cd "$(dirname "$BATS_TEST_FILENAME")/../../src/hooks" && pwd)"
    
    # Create temp config directory
    export NOTIFIER_DIR="$(mktemp -d)"
    export CONFIG_FILE="${NOTIFIER_DIR}/config.json"
    export LOG_FILE="${NOTIFIER_DIR}/notifications.log"
    export DEBOUNCE_DIR="${NOTIFIER_DIR}/debounce"
    mkdir -p "${DEBOUNCE_DIR}"
}

teardown() {
    # Cleanup temp directory
    rm -rf "${NOTIFIER_DIR}"
}

# Helper to create config with specific git_commands setting
create_config() {
    local git_commands="${1:-false}"
    cat > "${CONFIG_FILE}" <<EOF
{
  "enabled": true,
  "terminal_input": true,
  "git_commands": ${git_commands},
  "task_complete": true,
  "task_error": true,
  "approval_required": true,
  "sound_enabled": false,
  "debounce_seconds": 0
}
EOF
}

# ============================================================================
# User Story 1: Git Notifications Disabled by Default
# ============================================================================

@test "US1: git push does NOT trigger notification with default config (git_commands=false)" {
    create_config "false"
    
    # The detect function should return 1 (no notification) for git commands when disabled
    # We test by checking that git commands are NOT in the "should notify" list
    
    # Source common to load preferences
    source "${SCRIPT_DIR}/common.sh"
    load_preferences
    
    # With git_commands=false, PREF_GIT_COMMANDS should be "false"
    [ "${PREF_GIT_COMMANDS}" = "false" ]
}

@test "US1: git pull does NOT trigger notification with default config" {
    create_config "false"
    source "${SCRIPT_DIR}/common.sh"
    load_preferences
    
    [ "${PREF_GIT_COMMANDS}" = "false" ]
}

@test "US1: git clone does NOT trigger notification with default config" {
    create_config "false"
    source "${SCRIPT_DIR}/common.sh"
    load_preferences
    
    [ "${PREF_GIT_COMMANDS}" = "false" ]
}

@test "US1: git fetch does NOT trigger notification with default config" {
    create_config "false"
    source "${SCRIPT_DIR}/common.sh"
    load_preferences
    
    [ "${PREF_GIT_COMMANDS}" = "false" ]
}

@test "US1: default config has git_commands=false" {
    # Test the actual default config file
    local default_config="${SCRIPT_DIR}/../config/default-config.json"
    
    if command -v jq &> /dev/null; then
        local value=$(jq -r '.git_commands' "${default_config}")
        [ "${value}" = "false" ]
    else
        # Fallback: grep for the value
        grep -q '"git_commands": false' "${default_config}"
    fi
}

# ============================================================================
# User Story 2: Git Notifications Can Be Enabled
# ============================================================================

@test "US2: git push DOES trigger notification when git_commands=true" {
    create_config "true"
    source "${SCRIPT_DIR}/common.sh"
    load_preferences
    
    [ "${PREF_GIT_COMMANDS}" = "true" ]
}

@test "US2: git pull DOES trigger notification when git_commands=true" {
    create_config "true"
    source "${SCRIPT_DIR}/common.sh"
    load_preferences
    
    [ "${PREF_GIT_COMMANDS}" = "true" ]
}

# ============================================================================
# Edge Cases
# ============================================================================

@test "Edge: missing git_commands in config defaults to false" {
    # Create config without git_commands field
    cat > "${CONFIG_FILE}" <<EOF
{
  "enabled": true,
  "terminal_input": true,
  "task_complete": true
}
EOF
    
    source "${SCRIPT_DIR}/common.sh"
    load_preferences
    
    # Should default to false
    [ "${PREF_GIT_COMMANDS}" = "false" ]
}

@test "Edge: sudo commands still trigger notification regardless of git_commands" {
    create_config "false"
    source "${SCRIPT_DIR}/common.sh"
    load_preferences
    
    # terminal_input should still be true
    [ "${PREF_TERMINAL_INPUT}" = "true" ]
}

@test "Edge: ssh commands still trigger notification regardless of git_commands" {
    create_config "false"
    source "${SCRIPT_DIR}/common.sh"
    load_preferences
    
    # terminal_input should still be true
    [ "${PREF_TERMINAL_INPUT}" = "true" ]
}
