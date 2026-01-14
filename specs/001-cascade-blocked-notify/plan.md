# Implementation Plan: Cascade Blocked Notification

**Branch**: `001-cascade-blocked-notify` | **Date**: 2026-01-14 | **Spec**: [spec.md](./spec.md)
**Input**: Feature specification from `/specs/001-cascade-blocked-notify/spec.md`

## Summary

Implement a notification system that alerts the user when Windsurf's Cascade is blocked (terminal input, approval required) or completes a task. Uses Cascade Hooks for detection and macOS native notifications for delivery. Notifications are suppressed when Windsurf is focused.

## Technical Context

**Language/Version**: Bash/Shell (primary), Python 3.x (fallback if needed)  
**Primary Dependencies**: Cascade Hooks API, macOS `osascript` (AppleScript), `jq` for JSON parsing  
**Storage**: Text file logging (~/.windsurf-notifier/notifications.log)  
**Testing**: Shell-based BDD tests using BATS (Bash Automated Testing System)  
**Target Platform**: macOS (user's OS)  
**Project Type**: Single project (hook scripts + configuration)  
**Performance Goals**: Notifications appear within 10 seconds of event detection  
**Constraints**: <1 second hook execution time, no external service dependencies  
**Scale/Scope**: Single user, local machine only

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

### I. Behavior-Driven Development (BDD) ✅

| Requirement | Status | Evidence |
|-------------|--------|----------|
| Given/When/Then acceptance criteria | ✅ PASS | Spec contains 7 BDD scenarios across 3 user stories |
| Ubiquitous language | ✅ PASS | Domain terms: BlockingEvent, Notification, Cascade Hooks |
| Living documentation | ✅ PASS | Scenarios map directly to testable behaviors |
| Outside-in development | ✅ PASS | User stories drive implementation, not tech choices |

### II. Production Environment Verification ✅

| Requirement | Status | Evidence |
|-------------|--------|----------|
| Real environment testing | ✅ PASS | Tests will run against actual Windsurf with real hooks |
| No mock-only validation | ✅ PASS | Integration tests trigger real notifications |
| Smoke tests on deploy | ✅ PASS | quickstart.md will include verification steps |
| Observability | ✅ PASS | FR-011 requires file-based logging |

**Gate Status**: ✅ PASSED - Proceed to Phase 0

## Project Structure

### Documentation (this feature)

```text
specs/001-cascade-blocked-notify/
├── plan.md              # This file
├── research.md          # Phase 0 output
├── data-model.md        # Phase 1 output
├── quickstart.md        # Phase 1 output
├── contracts/           # Phase 1 output (hook JSON schemas)
└── tasks.md             # Phase 2 output (/speckit.tasks command)
```

### Source Code (repository root)

```text
src/
├── hooks/
│   ├── post_run_command.sh      # Hook: detect command completion/blocking
│   ├── post_cascade_response.sh # Hook: detect task completion
│   └── common.sh                # Shared functions (notify, log, focus-check)
├── config/
│   └── hooks.json               # Windsurf hooks configuration
└── lib/
    └── notifier.sh              # Core notification logic

tests/
├── integration/
│   ├── test_terminal_blocked.bats
│   ├── test_task_complete.bats
│   └── test_approval_required.bats
└── unit/
    ├── test_notifier.bats
    └── test_focus_detection.bats

install.sh                       # Installation script
README.md                        # Project documentation
```

**Structure Decision**: Single project with shell scripts. Hooks directory contains entry points called by Cascade. Lib contains reusable notification logic. Tests use BATS framework for BDD-style shell testing.

## Complexity Tracking

> No violations - design follows constitution principles.
