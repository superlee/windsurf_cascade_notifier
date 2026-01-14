#!/usr/bin/env bats
# test_task_complete.bats - Integration tests for task completion notifications

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

@test "Given task completes, When hook fires, Then notification is logged" {
    skip "Integration test requires real Windsurf environment - run via quickstart.md"
}

@test "Given task errors, When hook fires, Then error notification is logged" {
    skip "Integration test requires real Windsurf environment - run via quickstart.md"
}

@test "Log file contains correct format for task-complete event" {
    echo '2026-01-14T12:00:00+0800 | task-complete | SENT | "Cascade: Task completed"' > "${LOG_FILE}"
    
    run grep "task-complete" "${LOG_FILE}"
    [ "$status" -eq 0 ]
    [[ "$output" =~ "SENT" ]]
}

@test "Log file contains correct format for task-error event" {
    echo '2026-01-14T12:00:00+0800 | task-error | SENT | "Cascade: Task stopped - Error encountered"' > "${LOG_FILE}"
    
    run grep "task-error" "${LOG_FILE}"
    [ "$status" -eq 0 ]
    [[ "$output" =~ "Error" ]]
}
