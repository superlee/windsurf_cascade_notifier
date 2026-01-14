# Implementation Plan: Hooks.json Install/Uninstall Management

**Branch**: `003-hooks-json-install` | **Date**: 2026-01-14 | **Spec**: [spec.md](./spec.md)
**Input**: Feature specification from `/specs/003-hooks-json-install/spec.md`

## Summary

Update install.sh and uninstall.sh to manage the user-level hooks configuration at `~/.codeium/windsurf/hooks.json` on macOS. The installer will merge notifier hooks into existing configuration (preserving other hooks), and the uninstaller will cleanly remove only notifier-related entries (identified by `~/.windsurf-notifier/` path pattern).

## Technical Context

**Language/Version**: Bash/Shell (existing codebase)  
**Primary Dependencies**: jq (JSON parsing - already required)  
**Storage**: JSON config file (~/.codeium/windsurf/hooks.json)  
**Testing**: BATS (Bash Automated Testing System)  
**Target Platform**: macOS  
**Project Type**: Single project (installer script modifications)  
**Performance Goals**: N/A (one-time install/uninstall)  
**Constraints**: Must preserve existing hooks, must be idempotent  
**Scale/Scope**: 2 files modified (install.sh, uninstall.sh)

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

### I. Behavior-Driven Development (BDD) ✅

| Requirement | Status | Evidence |
|-------------|--------|----------|
| Given/When/Then acceptance criteria | ✅ PASS | Spec contains 6 BDD scenarios across 2 user stories |
| Ubiquitous language | ✅ PASS | Domain terms: hooks.json, notifier hooks, merge |
| Living documentation | ✅ PASS | Scenarios map directly to testable behaviors |
| Outside-in development | ✅ PASS | User need (global hooks) drives implementation |

### II. Production Environment Verification ✅

| Requirement | Status | Evidence |
|-------------|--------|----------|
| Real environment testing | ✅ PASS | Tests run against actual ~/.codeium/windsurf/ path |
| No mock-only validation | ✅ PASS | Integration test will verify real hooks.json |
| Smoke tests on deploy | ✅ PASS | quickstart.md will include verification steps |
| Observability | ✅ PASS | Backup files created before modification |

**Gate Status**: ✅ PASSED - Proceed to Phase 0

## Project Structure

### Documentation (this feature)

```text
specs/003-hooks-json-install/
├── plan.md              # This file
├── research.md          # Phase 0 output (minimal - no unknowns)
├── quickstart.md        # Phase 1 output
└── tasks.md             # Phase 2 output (/speckit.tasks command)
```

### Source Code (files to modify)

```text
./
├── install.sh           # MODIFY: Add user-level hooks.json management
├── uninstall.sh         # MODIFY: Add hooks.json cleanup
└── src/
    └── lib/
        └── hooks_manager.sh  # NEW: Shared functions for hooks.json manipulation

tests/
└── unit/
    └── test_hooks_manager.bats  # NEW: Tests for hooks.json management
```

**Structure Decision**: Minimal changes to existing installer scripts. New shared library for JSON manipulation to avoid code duplication.

## Complexity Tracking

> No violations - simple script modification follows existing patterns.
