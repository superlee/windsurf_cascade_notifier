# Research: Optional Git Command Notifications

**Feature**: 002-optional-git-notify  
**Date**: 2026-01-14

## Overview

This feature adds a simple configuration option. No significant research required - follows existing patterns in the codebase.

## Decision 1: Configuration Key Name

**Decision**: `git_commands`

**Rationale**: 
- Consistent with existing config keys (`terminal_input`, `task_complete`, etc.)
- Clear and descriptive
- Boolean type matches other notification toggles

**Alternatives Considered**:
- `git_notifications` - rejected (redundant "notifications" suffix)
- `notify_git` - rejected (inconsistent with existing naming pattern)

## Decision 2: Default Value

**Decision**: `false` (disabled by default)

**Rationale**:
- User explicitly requested this default
- Most developers use SSH keys or credential helpers (no password prompts)
- Reduces notification noise for majority of users
- Backward compatible - existing users won't see new notifications

**Alternatives Considered**:
- `true` (enabled) - rejected (causes unwanted notifications for most users)

## Decision 3: Implementation Approach

**Decision**: Check `git_commands` preference in `detect_terminal_input()` function before matching git command patterns

**Rationale**:
- Minimal code change
- Single point of control
- Preserves existing behavior for non-git commands
- Allows password prompt detection to still work if actual prompt appears in output

## Dependencies

No new dependencies required. Uses existing:
- `jq` for JSON parsing
- Config file structure already in place

## Risks

| Risk | Mitigation |
|------|------------|
| Breaking existing config | Default to `false` if key missing |
| User confusion | Document in README and quickstart |

## Summary

Simple feature with no technical unknowns. Proceed to implementation.
