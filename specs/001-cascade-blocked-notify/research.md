# Research: Cascade Blocked Notification

**Feature**: 001-cascade-blocked-notify  
**Date**: 2026-01-14

## Research Areas

### 1. Cascade Hooks API

**Decision**: Use `post_run_command` and `post_cascade_response` hooks

**Rationale**:
- Cascade Hooks provide native integration with Windsurf without external monitoring
- Hooks receive JSON context via stdin with trajectory_id, execution_id, timestamp, and tool_info
- `post_run_command` fires after every terminal command - can analyze output for blocking patterns
- `post_cascade_response` fires after Cascade completes a response - ideal for task completion detection

**Alternatives Considered**:
- External process monitoring terminal output: Rejected - requires complex file watching, race conditions
- Windsurf extension API: Rejected - no public extension API available
- Manual triggers: Rejected - defeats purpose of automatic notification

**Hook Configuration** (from docs):
```json
{
  "hooks": {
    "post_run_command": [
      {
        "command": "bash /path/to/hook.sh",
        "show_output": false
      }
    ]
  }
}
```

**Input JSON Structure**:
```json
{
  "agent_action_name": "post_run_command",
  "trajectory_id": "unique-id",
  "execution_id": "exec-id",
  "timestamp": "2026-01-14T12:00:00Z",
  "tool_info": {
    "command_line": "sudo apt install...",
    "cwd": "/path/to/project"
  }
}
```

### 2. macOS Notification Delivery

**Decision**: Use `osascript` with AppleScript for notifications

**Rationale**:
- Native to macOS, no additional dependencies required
- Supports notification sounds
- Can trigger actions on click
- Works reliably across macOS versions

**Alternatives Considered**:
- `terminal-notifier`: Good but requires Homebrew installation - adds dependency
- Swift binary: More powerful but requires compilation, overkill for shell-based solution
- `alerter`: Similar to terminal-notifier, external dependency

**Implementation**:
```bash
osascript -e 'display notification "Body text" with title "Title" sound name "default"'
```

**Click-to-Focus**: Requires separate approach - AppleScript `activate` command:
```bash
osascript -e 'tell application "Windsurf" to activate'
```

**Limitation**: Native `display notification` doesn't support click callbacks. For click-to-focus, we'll use `terminal-notifier` if available (graceful enhancement), otherwise notification only alerts without focus action.

### 3. Window Focus Detection

**Decision**: Use AppleScript to check frontmost application

**Rationale**:
- Native macOS approach, no external tools needed
- Fast execution (<100ms)
- Reliable across macOS versions

**Implementation**:
```bash
frontmost=$(osascript -e 'tell application "System Events" to get name of first application process whose frontmost is true')
if [ "$frontmost" = "Windsurf" ]; then
  # Suppress notification
fi
```

**Alternatives Considered**:
- `lsappinfo`: Lower-level but less readable
- Python with AppKit: Adds Python dependency
- Accessibility API: Requires permissions, complex

### 4. JSON Parsing in Bash

**Decision**: Use `jq` for JSON parsing

**Rationale**:
- Standard tool for JSON in shell scripts
- Likely already installed on developer machines
- Clean, readable syntax
- Handles nested structures well

**Fallback**: If `jq` not available, use Python one-liner:
```bash
python3 -c "import sys,json; print(json.load(sys.stdin)['tool_info']['command_line'])"
```

**Alternatives Considered**:
- `grep`/`sed`: Fragile, breaks on nested JSON
- `awk`: Complex for JSON parsing
- Pure bash: Not practical for JSON

### 5. Debouncing Strategy

**Decision**: File-based timestamp tracking with 5-second window

**Rationale**:
- Simple, no background process needed
- Survives script restarts
- Easy to debug via log file

**Implementation**:
```bash
DEBOUNCE_FILE="$HOME/.windsurf-notifier/last_notification"
DEBOUNCE_SECONDS=5

last_time=$(cat "$DEBOUNCE_FILE" 2>/dev/null || echo 0)
current_time=$(date +%s)

if [ $((current_time - last_time)) -ge $DEBOUNCE_SECONDS ]; then
  # Send notification
  echo "$current_time" > "$DEBOUNCE_FILE"
fi
```

### 6. Testing Framework

**Decision**: BATS (Bash Automated Testing System)

**Rationale**:
- Purpose-built for testing Bash scripts
- TAP-compliant output
- Supports setup/teardown
- Easy BDD-style test naming

**Installation**: `brew install bats-core`

**Example Test**:
```bash
@test "Given Windsurf not focused, When notification triggered, Then osascript is called" {
  # Mock focus check to return "Safari"
  export MOCK_FRONTMOST="Safari"
  
  run ./src/lib/notifier.sh "Test title" "Test body"
  
  [ "$status" -eq 0 ]
  [[ "$output" =~ "notification sent" ]]
}
```

## Risks & Mitigations

| Risk | Mitigation |
|------|------------|
| `jq` not installed | Fallback to Python JSON parsing |
| `terminal-notifier` not installed | Graceful degradation - notifications work, click-to-focus doesn't |
| Hook script takes too long | Keep processing under 1 second, log and exit on timeout |
| Notification spam | Debounce with 5-second window per event type |

## Dependencies Summary

| Dependency | Required | Fallback |
|------------|----------|----------|
| Bash 4+ | Yes | None (macOS default) |
| osascript | Yes | None (macOS native) |
| jq | Preferred | Python 3 |
| terminal-notifier | Optional | Click-to-focus disabled |
| BATS | Dev only | Manual testing |
