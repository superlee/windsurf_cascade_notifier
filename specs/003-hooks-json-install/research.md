# Research: Hooks.json Install/Uninstall Management

**Feature**: 003-hooks-json-install  
**Date**: 2026-01-14

## Overview

This feature modifies existing install/uninstall scripts. No significant unknowns - follows established patterns in codebase.

## Decision 1: Hooks.json Location

**Decision**: `~/.codeium/windsurf/hooks.json`

**Rationale**: 
- This is the user-level hooks location on macOS
- Works globally across all projects (unlike project-level `.windsurf/hooks.json`)
- User explicitly requested this path

**Alternatives Considered**:
- Project-level `.windsurf/hooks.json` - rejected (current behavior, requires per-project setup)

## Decision 2: Hook Identification for Removal

**Decision**: Match hooks by command path containing `~/.windsurf-notifier/`

**Rationale**:
- Simple string matching on existing command paths
- No additional markers or files needed
- All notifier hooks already use this path pattern
- Clarified with user during /speckit.clarify

**Alternatives Considered**:
- Add metadata field to hook entries - rejected (modifies hooks.json structure)
- Separate manifest file - rejected (adds complexity)

## Decision 3: JSON Manipulation Approach

**Decision**: Use `jq` for JSON manipulation

**Rationale**:
- Already a project dependency
- Reliable JSON parsing and manipulation
- Can merge arrays and filter entries cleanly

**Implementation Pattern**:
```bash
# Merge hooks into existing array
jq '.hooks.post_run_command += [NEW_HOOK]' hooks.json

# Remove hooks by path pattern
jq '.hooks.post_run_command |= map(select(.command | contains("~/.windsurf-notifier/") | not))' hooks.json
```

## Decision 4: Backup Strategy

**Decision**: Create timestamped backup before modification

**Rationale**:
- FR-008 requires backup before modification
- Timestamped files allow multiple backups
- User can restore manually if needed

**Pattern**: `hooks.json.backup.YYYYMMDD_HHMMSS`

## Dependencies

No new dependencies. Uses existing:
- `jq` for JSON parsing
- Standard bash utilities

## Risks

| Risk | Mitigation |
|------|------------|
| Corrupting existing hooks.json | Backup before modification |
| jq not installed | Check and warn, fall back to error |
| Permission issues | Check write permission, report clear error |

## Summary

Simple feature with no technical unknowns. Proceed to implementation.
