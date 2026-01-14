# Feature Specification: Optional Git Command Notifications

**Feature Branch**: `002-optional-git-notify`  
**Created**: 2026-01-14  
**Status**: Ready  
**Input**: User description: "The git related command don't need any password. Make git command notification optional, and disable by default"

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Disable Git Notifications by Default (Priority: P1)

As a developer using SSH keys or credential helpers for Git authentication, I want git command notifications to be disabled by default so that I don't receive unnecessary "waiting for input" alerts for commands that never require manual password entry.

**Why this priority**: This is the core request - most developers use passwordless Git authentication (SSH keys, credential managers, tokens). The current behavior creates noise by alerting on every git push/pull/fetch/clone.

**Independent Test**: Can be fully tested by running `git push` with default config and verifying no notification appears.

**Acceptance Scenarios**:

1. **Given** a fresh installation with default configuration, **When** Cascade executes `git push`, **Then** no "terminal waiting for input" notification is sent

2. **Given** a fresh installation with default configuration, **When** Cascade executes `git pull`, **Then** no notification is sent for the git command

3. **Given** default configuration, **When** Cascade executes `git clone https://...`, **Then** no notification is sent

---

### User Story 2 - Enable Git Notifications Optionally (Priority: P2)

As a developer who uses HTTPS Git authentication with manual password entry, I want to be able to enable git command notifications so that I get alerted when Git prompts for credentials.

**Why this priority**: Some users may still need Git notifications if they use password-based authentication. This provides flexibility.

**Independent Test**: Can be fully tested by enabling git_commands in config, running `git push`, and verifying notification appears.

**Acceptance Scenarios**:

1. **Given** configuration has `git_commands` set to `true`, **When** Cascade executes `git push`, **Then** a "terminal waiting for input" notification is sent

2. **Given** configuration has `git_commands` set to `true`, **When** Cascade executes any git remote operation (push/pull/fetch/clone), **Then** a notification is sent

---

### Edge Cases

- What happens when config file is missing the new `git_commands` setting? System MUST default to `false` (disabled).
- What happens when user upgrades from previous version without the setting? System MUST preserve backward compatibility by defaulting to disabled.
- What happens with git commands that never prompt (e.g., `git status`, `git log`)? System MUST NOT notify for local-only git operations regardless of setting.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST add a `git_commands` configuration option to control git-related notifications
- **FR-002**: System MUST default `git_commands` to `false` (disabled) in new installations
- **FR-003**: System MUST skip notification for git push/pull/fetch/clone commands when `git_commands` is `false`
- **FR-004**: System MUST send notification for git push/pull/fetch/clone commands when `git_commands` is `true`
- **FR-005**: System MUST NOT affect notifications for other terminal commands (sudo, ssh, docker login)
- **FR-006**: System MUST continue to detect actual password prompts in terminal output regardless of `git_commands` setting

### Key Entities

- **UserPreferences**: Extended with `git_commands` boolean field (default: `false`)

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Zero notifications for git commands with default configuration
- **SC-002**: User can enable git notifications within 30 seconds by editing config
- **SC-003**: Non-git terminal blocking notifications (sudo, ssh) continue to work unchanged
- **SC-004**: Existing users upgrading receive no git notifications without explicit opt-in
