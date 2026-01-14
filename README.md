# Windsurf Cascade Notifier

Desktop notifications for Windsurf's Cascade AI assistant.

## Features

- **Terminal Blocking Detection**: Get notified when Cascade is waiting for password input
- **Task Completion Alerts**: Know when Cascade finishes a task
- **Approval Prompts**: Never miss when Cascade needs your approval
- **Smart Suppression**: Notifications only appear when Windsurf isn't focused

## Requirements

- macOS (uses native notification system)
- Windsurf IDE with Cascade Hooks support
- `jq` (recommended): `brew install jq`

## Installation

```bash
./install.sh
```

This will:
1. Copy hook scripts to `~/.windsurf-notifier/`
2. Create default configuration
3. Set up Windsurf hooks

## Configuration

Edit `~/.windsurf-notifier/config.json`:

```json
{
  "enabled": true,
  "terminal_input": true,
  "task_complete": true,
  "task_error": true,
  "approval_required": true,
  "sound_enabled": true,
  "debounce_seconds": 5
}
```

### Configuration Options

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `enabled` | boolean | `true` | Master switch for all notifications |
| `terminal_input` | boolean | `true` | Notify when terminal waits for input (passwords) |
| `task_complete` | boolean | `true` | Notify when Cascade completes a task |
| `task_error` | boolean | `true` | Notify when Cascade encounters an error |
| `approval_required` | boolean | `true` | Notify when Cascade needs approval |
| `sound_enabled` | boolean | `true` | Play sound with notifications |
| `debounce_seconds` | integer | `5` | Minimum seconds between notifications |

Changes take effect immediately (no restart needed).

## Usage

Once installed, notifications appear automatically when:
- Cascade is blocked waiting for terminal input (e.g., password)
- Cascade completes a task
- Cascade needs your approval to proceed

Notifications are suppressed when Windsurf is the active window.

## Logs

View notification history:

```bash
tail -f ~/.windsurf-notifier/notifications.log
```

## Uninstall

```bash
./uninstall.sh
```

## License

MIT
