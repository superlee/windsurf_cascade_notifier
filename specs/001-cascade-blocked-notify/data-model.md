# Data Model: Cascade Blocked Notification

**Feature**: 001-cascade-blocked-notify  
**Date**: 2026-01-14

## Entities

### BlockingEvent

Represents a detected condition that may warrant user notification.

| Field | Type | Description |
|-------|------|-------------|
| `event_type` | enum | `terminal-input` \| `task-complete` \| `task-error` \| `approval-required` |
| `timestamp` | ISO 8601 string | When the event was detected |
| `trajectory_id` | string | Cascade conversation identifier |
| `execution_id` | string | Single agent turn identifier |
| `context` | object | Event-specific details (see below) |

**Context by Event Type**:

- `terminal-input`: `{ command_line: string, cwd: string }`
- `task-complete`: `{ response_summary: string }` 
- `task-error`: `{ error_message: string }`
- `approval-required`: `{ action_description: string }`

### Notification

Represents a user-facing notification to be sent.

| Field | Type | Description |
|-------|------|-------------|
| `title` | string | Notification title (e.g., "Cascade: Task completed") |
| `body` | string | Notification body with context |
| `event_type` | enum | Source event type |
| `sent_at` | ISO 8601 string | When notification was sent |
| `suppressed` | boolean | True if suppressed due to focus/debounce |
| `suppression_reason` | string | `windsurf-focused` \| `debounced` \| null |

### UserPreferences

User's notification settings stored in config file.

| Field | Type | Default | Description |
|-------|------|---------|-------------|
| `enabled` | boolean | `true` | Master enable/disable |
| `terminal_input` | boolean | `true` | Notify on terminal blocking |
| `task_complete` | boolean | `true` | Notify on task completion |
| `task_error` | boolean | `true` | Notify on task errors |
| `approval_required` | boolean | `true` | Notify on approval needed |
| `sound_enabled` | boolean | `true` | Play notification sound |
| `debounce_seconds` | integer | `5` | Minimum seconds between notifications |

**Storage Location**: `~/.windsurf-notifier/config.json`

## State Transitions

### Notification Lifecycle

```
[Event Detected] 
    ↓
[Check Preferences] → (disabled) → [Log & Exit]
    ↓ (enabled)
[Check Window Focus] → (Windsurf focused) → [Log suppressed & Exit]
    ↓ (not focused)
[Check Debounce] → (within window) → [Log suppressed & Exit]
    ↓ (outside window)
[Send Notification]
    ↓
[Log sent]
    ↓
[Update debounce timestamp]
```

## File Structures

### hooks.json (Windsurf configuration)

```json
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
```

### config.json (User preferences)

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

### notifications.log (Debug log format)

```
2026-01-14T12:00:00+0800 | terminal-input | SENT | "Cascade blocked: Terminal waiting for input"
2026-01-14T12:00:03+0800 | terminal-input | SUPPRESSED | debounced
2026-01-14T12:00:10+0800 | task-complete | SUPPRESSED | windsurf-focused
2026-01-14T12:01:00+0800 | task-complete | SENT | "Cascade: Task completed"
```

## Validation Rules

1. `event_type` MUST be one of the defined enum values
2. `timestamp` MUST be valid ISO 8601 format
3. `debounce_seconds` MUST be >= 0
4. `title` MUST NOT exceed 100 characters
5. `body` MUST NOT exceed 500 characters
