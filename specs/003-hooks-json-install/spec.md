# Feature Specification: Hooks.json Install/Uninstall Management

**Feature Branch**: `003-hooks-json-install`  
**Created**: 2026-01-14  
**Status**: Ready  
**Input**: User description: "install.sh and uninstall.sh need to update ~/.codeium/windsurf/hooks.json file on macOS"

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Auto-configure User-Level Hooks on Install (Priority: P1)

As a user installing the Windsurf Cascade Notifier on macOS, I want the installer to automatically configure the user-level hooks.json file at `~/.codeium/windsurf/hooks.json` so that the notification hooks work globally across all my projects without manual configuration.

**Why this priority**: This is the core installation experience. Without proper hooks.json configuration, the notifier won't work at all. The user-level config ensures hooks work in any project directory.

**Independent Test**: Run `./install.sh` on a fresh system, then verify `~/.codeium/windsurf/hooks.json` contains the notifier hook entries.

**Acceptance Scenarios**:

1. **Given** no existing `~/.codeium/windsurf/hooks.json`, **When** user runs `./install.sh`, **Then** the file is created with the notifier hook configuration

2. **Given** an existing `~/.codeium/windsurf/hooks.json` with other hooks, **When** user runs `./install.sh`, **Then** the notifier hooks are added/merged without removing existing hooks

3. **Given** an existing `~/.codeium/windsurf/hooks.json` already containing notifier hooks, **When** user runs `./install.sh`, **Then** the hooks are updated to the latest paths without duplication

---

### User Story 2 - Clean Uninstall of Hooks (Priority: P2)

As a user uninstalling the Windsurf Cascade Notifier, I want the uninstaller to remove the notifier hook entries from `~/.codeium/windsurf/hooks.json` so that Windsurf doesn't try to execute non-existent hooks after uninstallation.

**Why this priority**: Clean uninstall prevents errors after removal. Without this, Windsurf would attempt to run deleted hook scripts.

**Independent Test**: After running `./uninstall.sh`, verify the notifier entries are removed from `~/.codeium/windsurf/hooks.json` while other hooks remain intact.

**Acceptance Scenarios**:

1. **Given** `~/.codeium/windsurf/hooks.json` contains only notifier hooks, **When** user runs `./uninstall.sh`, **Then** the notifier hooks are removed (file may be left empty or deleted)

2. **Given** `~/.codeium/windsurf/hooks.json` contains notifier hooks AND other hooks, **When** user runs `./uninstall.sh`, **Then** only the notifier hooks are removed, other hooks remain

3. **Given** `~/.codeium/windsurf/hooks.json` does not exist, **When** user runs `./uninstall.sh`, **Then** uninstall completes without error

---

### Edge Cases

- What happens when `~/.codeium/windsurf/` directory doesn't exist? Install MUST create it.
- What happens when hooks.json is malformed/invalid JSON? Install SHOULD backup and recreate, or warn user.
- What happens when hooks.json has read-only permissions? Install/uninstall MUST report clear error.
- What happens when the existing project-level `.windsurf/hooks.json` also exists? User-level takes precedence in Windsurf; install SHOULD inform user.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: Install script MUST target user-level hooks at `~/.codeium/windsurf/hooks.json` on macOS
- **FR-002**: Install script MUST create parent directories (`~/.codeium/windsurf/`) if they don't exist
- **FR-003**: Install script MUST merge notifier hooks into existing hooks.json without removing other hooks
- **FR-004**: Install script MUST update existing notifier hook entries if already present (idempotent)
- **FR-005**: Uninstall script MUST remove only notifier-related hook entries (identified by command path containing `~/.windsurf-notifier/`) from hooks.json
- **FR-006**: Uninstall script MUST preserve other (non-notifier) hooks in the file
- **FR-007**: Both scripts MUST handle missing hooks.json gracefully (no errors)
- **FR-008**: Both scripts MUST backup hooks.json before modification
- **FR-009**: Install script SHOULD warn user if project-level `.windsurf/hooks.json` also exists

### Key Entities

- **HooksConfig**: The JSON structure in hooks.json containing hook arrays for `post_run_command` and `post_cascade_response`
- **HookEntry**: Individual hook definition with `command` path and `show_output` flag

## Clarifications

### Session 2026-01-14

- Q: How should the uninstaller identify notifier hooks for removal? → A: Match by command path containing `~/.windsurf-notifier/`

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Fresh install creates working hooks.json in under 5 seconds
- **SC-002**: Install on existing hooks.json preserves 100% of non-notifier hooks
- **SC-003**: Uninstall removes all notifier hooks while preserving 100% of other hooks
- **SC-004**: Re-running install multiple times produces identical result (idempotent)
- **SC-005**: After install, Windsurf successfully executes notifier hooks in any project directory
