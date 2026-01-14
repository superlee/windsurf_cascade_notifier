# Quickstart: Cascade Blocked Notification

Get desktop notifications when Windsurf's Cascade is blocked or completes tasks.

## Prerequisites

- macOS (tested on macOS 12+)
- Windsurf IDE with Cascade Hooks support
- `jq` (recommended): `brew install jq`
- `bats-core` (for testing): `brew install bats-core`

## Installation

### 1. Clone and Install

```bash
cd ~/repo/windsurf_cascade_notifier
./install.sh
```

The installer will:
- Create `~/.windsurf-notifier/` directory
- Copy hook scripts to `~/.windsurf-notifier/hooks/`
- Create default config at `~/.windsurf-notifier/config.json`
- Configure Windsurf hooks in `.windsurf/hooks.json`

### 2. Manual Installation (Alternative)

```bash
# Create directories
mkdir -p ~/.windsurf-notifier/{hooks,logs}

# Copy scripts
cp src/hooks/*.sh ~/.windsurf-notifier/hooks/
cp src/lib/*.sh ~/.windsurf-notifier/lib/

# Create config
cat > ~/.windsurf-notifier/config.json << 'EOF'
{
  "enabled": true,
  "terminal_input": true,
  "task_complete": true,
  "task_error": true,
  "approval_required": true,
  "sound_enabled": true,
  "debounce_seconds": 5
}
EOF

# Configure Windsurf hooks (in your workspace)
mkdir -p .windsurf
cat > .windsurf/hooks.json << 'EOF'
{
  "hooks": {
    "post_run_command": [
      {
        "command": "bash ~/.windsurf-notifier/hooks/post_run_command.sh",
        "show_output": false
      }
    ],
    "post_cascade_response": [
      {
        "command": "bash ~/.windsurf-notifier/hooks/post_cascade_response.sh",
        "show_output": false
      }
    ]
  }
}
EOF
```

## Verification (Production Test)

Per constitution principle II, verify in real environment:

### Test 1: Terminal Input Notification (US1)

1. Open Windsurf and switch to another application (e.g., Terminal)
2. Ask Cascade: "Run `sudo echo hello`"
3. **Expected**: Desktop notification appears: "Cascade blocked: Terminal waiting for input"
4. Click notification or switch to Windsurf
5. Enter password in terminal
6. **Expected**: No duplicate notification

### Test 2: Task Completion Notification (US2)

1. Open Windsurf and switch to another application
2. Ask Cascade: "Create a file called test.txt with 'hello world'"
3. Wait for Cascade to complete
4. **Expected**: Desktop notification appears: "Cascade: Task completed"

### Test 3: Notification Suppression (Edge Case)

1. Keep Windsurf as the active/focused window
2. Ask Cascade: "Create a file called test2.txt"
3. **Expected**: NO notification (suppressed because Windsurf is focused)
4. Check log: `tail ~/.windsurf-notifier/notifications.log`
5. **Expected**: Log shows "SUPPRESSED | windsurf-focused"

## Configuration

Edit `~/.windsurf-notifier/config.json`:

```json
{
  "enabled": true,           // Master switch
  "terminal_input": true,    // Notify on password prompts
  "task_complete": true,     // Notify on task done
  "task_error": true,        // Notify on errors
  "approval_required": true, // Notify on approval needed
  "sound_enabled": true,     // Play notification sound
  "debounce_seconds": 5      // Min seconds between notifications
}
```

Changes take effect immediately (no restart needed).

## Troubleshooting

### No notifications appearing

1. Check if notifications are enabled in macOS System Settings > Notifications
2. Verify hook scripts are executable: `ls -la ~/.windsurf-notifier/hooks/`
3. Check logs: `tail -20 ~/.windsurf-notifier/notifications.log`

### Notifications appearing when Windsurf is focused

1. Verify AppleScript permission in System Settings > Privacy & Security > Automation
2. Test focus detection: `osascript -e 'tell application "System Events" to get name of first application process whose frontmost is true'`

### jq not found errors

Install jq or the scripts will fall back to Python:
```bash
brew install jq
```

## Logs

View notification history:
```bash
tail -f ~/.windsurf-notifier/notifications.log
```

Log format:
```
TIMESTAMP | EVENT_TYPE | STATUS | MESSAGE
```

## Uninstall

```bash
# Remove notifier files
rm -rf ~/.windsurf-notifier

# Remove hook configuration from workspace
rm .windsurf/hooks.json
```
