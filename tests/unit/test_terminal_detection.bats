#!/usr/bin/env bats
# test_terminal_detection.bats - Unit tests for terminal blocking detection

setup() {
    # Load the hook script functions
    export NOTIFIER_DIR="${BATS_TMPDIR}/windsurf-notifier"
    export DEBOUNCE_DIR="${NOTIFIER_DIR}/debounce"
    export LOG_FILE="${NOTIFIER_DIR}/notifications.log"
    mkdir -p "${NOTIFIER_DIR}" "${DEBOUNCE_DIR}"
    
    # Source library functions
    SCRIPT_DIR="$(cd "${BATS_TEST_DIRNAME}/../../src" && pwd)"
    source "${SCRIPT_DIR}/lib/json_parser.sh"
}

teardown() {
    rm -rf "${NOTIFIER_DIR}"
}

@test "detect_terminal_input returns true for Password: prompt" {
    # This test will fail until implementation is complete
    skip "Implementation pending - T015"
}

@test "detect_terminal_input returns true for passphrase prompt" {
    skip "Implementation pending - T015"
}

@test "detect_terminal_input returns true for sudo prompt" {
    skip "Implementation pending - T015"
}

@test "detect_terminal_input returns false for normal output" {
    skip "Implementation pending - T015"
}

@test "parse_hook_input extracts command_line from JSON" {
    local input='{"agent_action_name":"post_run_command","tool_info":{"command_line":"sudo apt install foo","cwd":"/tmp"}}'
    local result
    
    result=$(echo "${input}" | parse_hook_input "tool_info.command_line")
    
    [ "${result}" = "sudo apt install foo" ]
}

@test "parse_hook_input extracts cwd from JSON" {
    local input='{"agent_action_name":"post_run_command","tool_info":{"command_line":"ls","cwd":"/home/user"}}'
    local result
    
    result=$(echo "${input}" | parse_hook_input "tool_info.cwd")
    
    [ "${result}" = "/home/user" ]
}
