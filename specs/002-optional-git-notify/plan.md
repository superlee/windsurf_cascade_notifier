# Implementation Plan: Optional Git Command Notifications

**Branch**: `002-optional-git-notify` | **Date**: 2026-01-14 | **Spec**: [spec.md](./spec.md)
**Input**: Feature specification from `/specs/002-optional-git-notify/spec.md`

## Summary

Add a `git_commands` configuration option to control whether git push/pull/fetch/clone commands trigger "terminal waiting for input" notifications. Default to `false` (disabled) since most developers use passwordless Git authentication (SSH keys, credential helpers).

## Technical Context

**Language/Version**: Bash/Shell (existing codebase)  
**Primary Dependencies**: jq (JSON parsing), osascript (notifications)  
**Storage**: JSON config file (~/.windsurf-notifier/config.json)  
**Testing**: BATS (Bash Automated Testing System)  
**Target Platform**: macOS  
**Project Type**: Single project (config change to existing hook scripts)  
**Performance Goals**: N/A (config read only)  
**Constraints**: Backward compatible - existing users unaffected  
**Scale/Scope**: Single config option, 2 files modified

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

### I. Behavior-Driven Development (BDD) ✅

| Requirement | Status | Evidence |
|-------------|--------|----------|
| Given/When/Then acceptance criteria | ✅ PASS | Spec contains 5 BDD scenarios across 2 user stories |
| Ubiquitous language | ✅ PASS | Domain terms: git_commands, terminal-input notification |
| Living documentation | ✅ PASS | Scenarios map directly to testable behaviors |
| Outside-in development | ✅ PASS | User need drives config addition |

### II. Production Environment Verification ✅

| Requirement | Status | Evidence |
|-------------|--------|----------|
| Real environment testing | ✅ PASS | Tests run against actual Windsurf with real hooks |
| No mock-only validation | ✅ PASS | Integration test will run real git command |
| Smoke tests on deploy | ✅ PASS | quickstart.md will include verification |
| Observability | ✅ PASS | Existing logging captures suppressed notifications |

**Gate Status**: ✅ PASSED - Proceed to Phase 0

## Project Structure

### Documentation (this feature)

```text
specs/002-optional-git-notify/
├── plan.md              # This file
├── research.md          # Phase 0 output (minimal - no unknowns)
├── quickstart.md        # Phase 1 output
└── tasks.md             # Phase 2 output (/speckit.tasks command)
```

### Source Code (files to modify)

```text
src/
├── config/
│   └── default-config.json    # ADD: git_commands field (default: false)
├── hooks/
│   ├── common.sh              # ADD: load git_commands preference
│   └── post_run_command.sh    # MODIFY: check git_commands before notifying
└── lib/
    └── (no changes)

tests/
└── unit/
    └── test_git_notify.bats   # NEW: tests for git notification config
```

**Structure Decision**: Minimal change to existing codebase. Only 3 files modified, 1 test file added.

## Complexity Tracking

> No violations - simple config addition follows existing patterns.
