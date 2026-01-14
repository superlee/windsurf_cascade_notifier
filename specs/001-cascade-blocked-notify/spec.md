# Feature Specification: Cascade Blocked Notification

**Feature Branch**: `001-cascade-blocked-notify`  
**Created**: 2026-01-14  
**Status**: Clarified  
**Input**: User description: "I want windsurf to notify me whenever the cascade is blocked or stopped, e.g. in the terminal, it requires the password, and finish the task"

## Clarifications

### Session 2026-01-14

- Q: How will the system detect Cascade's blocking state? → A: Use Cascade Hooks (https://docs.windsurf.com/windsurf/cascade/hooks)
- Q: What programming language for hook scripts? → A: Bash/Shell preferred; Python fallback if needed
- Q: Should notifications fire when Windsurf is already focused? → A: Only notify when Windsurf is NOT the active window
- Q: Should the system log notification events? → A: Log to file (simple text log for debugging)

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Terminal Password Prompt Notification (Priority: P1)

As a developer using Windsurf, I want to receive a notification when Cascade is blocked waiting for terminal input (such as a password prompt) so that I can immediately provide the required input and unblock the workflow.

**Why this priority**: This is the most common blocking scenario mentioned by the user. Password prompts in terminal commands (sudo, SSH, git credentials) frequently block Cascade and require immediate attention to resume work.

**Independent Test**: Can be fully tested by triggering a sudo command that requires password input and verifying a notification appears within the configured threshold.

**Acceptance Scenarios**:

1. **Given** Cascade executes a terminal command requiring password input, **When** the terminal waits for input for more than 5 seconds, **Then** the user receives a desktop notification indicating "Cascade blocked: Terminal waiting for input"

2. **Given** a notification has been sent for a blocked terminal, **When** the user provides the required input and the command continues, **Then** no duplicate notifications are sent for the same blocking event

3. **Given** Cascade is blocked waiting for terminal input, **When** the user clicks the notification, **Then** the Windsurf window is brought to focus with the terminal panel visible

---

### User Story 2 - Task Completion Notification (Priority: P2)

As a developer, I want to receive a notification when Cascade finishes a task so that I can review the results without constantly monitoring the IDE.

**Why this priority**: Knowing when work is complete allows the user to context-switch to other tasks while Cascade works, improving productivity.

**Independent Test**: Can be fully tested by asking Cascade to perform a simple task and verifying a notification appears when the task completes.

**Acceptance Scenarios**:

1. **Given** Cascade is executing a multi-step task, **When** the task completes successfully, **Then** the user receives a desktop notification indicating "Cascade: Task completed"

2. **Given** Cascade encounters an error that stops execution, **When** the error occurs, **Then** the user receives a desktop notification indicating "Cascade: Task stopped - Error encountered"

---

### User Story 3 - User Approval Required Notification (Priority: P3)

As a developer, I want to receive a notification when Cascade requires my approval (e.g., to run a command or make changes) so that I don't leave Cascade waiting unnecessarily.

**Why this priority**: Approval gates are common in Cascade workflows but less frequent than password prompts or task completions.

**Independent Test**: Can be fully tested by triggering a command that requires user approval and verifying a notification appears.

**Acceptance Scenarios**:

1. **Given** Cascade proposes an action requiring user approval, **When** the approval prompt has been waiting for more than 10 seconds, **Then** the user receives a desktop notification indicating "Cascade: Waiting for your approval"

---

### Edge Cases

- What happens when multiple blocking events occur simultaneously? System MUST queue notifications and not overwhelm the user.
- What happens when Windsurf is already in focus? Notifications MUST be suppressed when Windsurf is the active window.
- What happens when the system notification service is unavailable? System MUST log the event and continue operating without crashing.
- What happens during rapid task completion (many small tasks)? System MUST debounce notifications to prevent notification spam.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST detect when Cascade terminal commands are waiting for user input
- **FR-002**: System MUST detect when Cascade tasks complete (success or error)
- **FR-003**: System MUST detect when Cascade is waiting for user approval
- **FR-004**: System MUST send desktop notifications via the operating system's native notification system
- **FR-005**: System MUST bring Windsurf to focus when the user clicks a notification
- **FR-006**: System MUST debounce notifications to prevent spam (minimum 5 seconds between notifications for the same event type)
- **FR-007**: System MUST support macOS notification system (user's OS)
- **FR-008**: Users MUST be able to configure notification preferences (enable/disable per event type)
- **FR-009**: System MUST include notification sound to alert the user audibly
- **FR-010**: System MUST detect if Windsurf is the active window and suppress notifications when focused
- **FR-011**: System MUST log all notification events to a text file for debugging purposes

### Integration & Dependencies

- **Cascade Hooks**: System uses Windsurf's native hook mechanism configured via `.windsurf/hooks.json`
  - `post_run_command`: Detect command completion/blocking states
  - `post_cascade_response`: Detect task completion
  - Hook scripts receive JSON context via stdin with trajectory_id, execution_id, timestamp, and tool_info
- **macOS Notification Center**: Native notification delivery via system APIs
- **Hook Configuration Locations**: Workspace-level (`.windsurf/hooks.json`) for project-specific notifications

### Technical Constraints

- **Scripting Language**: Bash/Shell preferred; Python fallback only when shell cannot achieve requirement
- **macOS Tools**: Use native `osascript` for notifications (AppleScript) or `terminal-notifier` if available

### Key Entities

- **BlockingEvent**: Represents a detected blocking condition (type: terminal-input | approval-required | task-complete, timestamp, context message)
- **Notification**: Represents a user-facing notification (title, body, event reference, sent timestamp, clicked status)
- **UserPreferences**: User's notification settings (enabled event types, sound enabled, focus-on-click enabled)

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Notifications appear within 10 seconds of a blocking event being detected
- **SC-002**: 100% of terminal password prompts trigger a notification when Windsurf is not in focus
- **SC-003**: Clicking a notification brings Windsurf to focus within 2 seconds
- **SC-004**: Zero duplicate notifications for the same blocking event
- **SC-005**: User can disable/enable notifications without restarting Windsurf
