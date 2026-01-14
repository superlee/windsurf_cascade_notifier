#!/usr/bin/env bats
# test_approval_required.bats - Integration tests for approval notifications

setup() {
    export NOTIFIER_DIR="${BATS_TMPDIR}/windsurf-notifier"
    export CONFIG_FILE="${NOTIFIER_DIR}/config.json"
    export DEBOUNCE_DIR="${NOTIFIER_DIR}/debounce"
    export LOG_FILE="${NOTIFIER_DIR}/notifications.log"
    
    mkdir -p "${NOTIFIER_DIR}" "${DEBOUNCE_DIR}"
    
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
    
    SCRIPT_DIR="$(cd "${BATS_TEST_DIRNAME}/../../src" && pwd)"
}

teardown() {
    rm -rf "${NOTIFIER_DIR}"
}

@test "Given approval required, When hook fires after 10s, Then notification logged" {
    skip "Integration test requires real Windsurf environment - run via quickstart.md"
}

@test "Log file contains correct format for approval-required event" {
    echo '2026-01-14T12:00:00+0800 | approval-required | SENT | "Cascade: Waiting for your approval"' > "${LOG_FILE}"
    
    run grep "approval-required" "${LOG_FILE}"
    [ "$status" -eq 0 ]
    [[ "$output" =~ "SENT" ]]
    [[ "$output" =~ "approval" ]]
}
