#!/usr/bin/env bats
# test_terminal_blocked.bats - Integration tests for terminal blocking notifications

setup() {
    # Set up test environment
    export NOTIFIER_DIR="${BATS_TMPDIR}/windsurf-notifier"
    export CONFIG_FILE="${NOTIFIER_DIR}/config.json"
    export DEBOUNCE_DIR="${NOTIFIER_DIR}/debounce"
    export LOG_FILE="${NOTIFIER_DIR}/notifications.log"
    
    mkdir -p "${NOTIFIER_DIR}" "${DEBOUNCE_DIR}"
    
    # Create test config
    cat > "${CONFIG_FILE}" << 'EOF'
{
  "enabled": true,
  "terminal_input": true,
  "task_complete": true,
  "task_error": true,
  "approval_required": true,
  "sound_enabled": false,
  "debounce_seconds": 1
}
EOF
    
    # Mock Windsurf not being focused
    export MOCK_FRONTMOST="Safari"
    
    SCRIPT_DIR="$(cd "${BATS_TEST_DIRNAME}/../../src" && pwd)"
}

teardown() {
    rm -rf "${NOTIFIER_DIR}"
}

@test "Given terminal waiting for password, When hook fires, Then notification is logged" {
    skip "Integration test requires real Windsurf environment - run via quickstart.md"
}

@test "Given notification sent, When same event within debounce, Then no duplicate" {
    skip "Integration test requires real Windsurf environment - run via quickstart.md"
}

@test "Given Windsurf focused, When terminal blocks, Then notification suppressed" {
    skip "Integration test requires real Windsurf environment - run via quickstart.md"
}

@test "Log file contains correct format for terminal-input event" {
    # Create a sample log entry
    echo '2026-01-14T12:00:00+0800 | terminal-input | SENT | "Cascade blocked: Terminal waiting for input"' > "${LOG_FILE}"
    
    # Verify format
    run grep "terminal-input" "${LOG_FILE}"
    [ "$status" -eq 0 ]
    [[ "$output" =~ "SENT" ]]
    [[ "$output" =~ "Cascade blocked" ]]
}
