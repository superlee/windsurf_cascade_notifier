# Tasks: Optional Git Command Notifications

**Input**: Design documents from `/specs/002-optional-git-notify/`
**Prerequisites**: plan.md ✅, spec.md ✅, research.md ✅, quickstart.md ✅

**Tests**: BATS tests included per constitution principle I (BDD)

**Organization**: Tasks grouped by user story for independent implementation and testing.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (US1, US2)
- Exact file paths included in descriptions

---

## Phase 1: Setup

**Purpose**: Add configuration option to existing codebase

- [x] T001 Add `git_commands` field (default: false) to src/config/default-config.json
- [x] T002 [P] Add `PREF_GIT_COMMANDS` loading to src/hooks/common.sh

---

## Phase 2: User Story 1 - Disable Git Notifications by Default (Priority: P1) 🎯 MVP

**Goal**: Git commands (push/pull/fetch/clone) do NOT trigger notifications with default config

**Independent Test**: Run `git push` with default config, verify no notification appears

### Tests for User Story 1

- [x] T003 [P] [US1] Create BATS test for git notification disabled in tests/unit/test_git_notify.bats

### Implementation for User Story 1

- [x] T004 [US1] Modify detect_terminal_input() to check git_commands preference in src/hooks/post_run_command.sh
- [x] T005 [US1] Skip git command patterns when git_commands is false in src/hooks/post_run_command.sh

**Checkpoint**: User Story 1 complete - git notifications disabled by default

---

## Phase 3: User Story 2 - Enable Git Notifications Optionally (Priority: P2)

**Goal**: Users can enable git notifications by setting `git_commands: true`

**Independent Test**: Set `git_commands: true`, run `git push`, verify notification appears

### Tests for User Story 2

- [x] T006 [P] [US2] Add BATS test for git notification enabled in tests/unit/test_git_notify.bats

### Implementation for User Story 2

- [x] T007 [US2] Ensure git command patterns trigger notification when git_commands is true in src/hooks/post_run_command.sh

**Checkpoint**: User Story 2 complete - git notifications can be enabled optionally

---

## Phase 4: Polish & Cross-Cutting Concerns

**Purpose**: Documentation and validation

- [x] T008 [P] Update README.md with git_commands configuration option
- [x] T009 [P] Reinstall to ~/.windsurf-notifier/ with updated files
- [x] T010 Run quickstart.md validation (production environment test per constitution II)

---

## Dependencies & Execution Order

### Phase Dependencies

```
Phase 1 (Setup)
    ↓
Phase 2 (US1 - MVP) ← git notifications disabled
    ↓
Phase 3 (US2) ← git notifications can be enabled
    ↓
Phase 4 (Polish)
```

### User Story Dependencies

| Story | Can Start After | Dependencies on Other Stories |
|-------|-----------------|-------------------------------|
| US1 (P1) | Phase 1 complete | None - fully independent |
| US2 (P2) | US1 complete | Uses same config field, builds on US1 logic |

### Within Each User Story

1. Tests MUST be written and FAIL before implementation (BDD)
2. Config changes before hook modifications
3. Story complete before moving to next priority

### Parallel Opportunities

**Phase 1**: T001, T002 can run in parallel
**Phase 2**: T003 runs first (test), then T004, T005 sequentially (same file)
**Phase 3**: T006 runs first (test), then T007
**Phase 4**: T008, T009 can run in parallel

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup (T001-T002)
2. Complete Phase 2: User Story 1 (T003-T005)
3. **STOP and VALIDATE**: Run quickstart.md Test 1
4. Deploy if ready - git notifications disabled by default!

### Incremental Delivery

| Milestone | Stories Complete | User Value |
|-----------|------------------|------------|
| MVP | US1 | Git commands don't trigger notifications |
| v1.1 | US1 + US2 | Users can opt-in to git notifications |
| v1.2 | All + Polish | Production-ready with docs |

### File Changes Summary

| File | Change Type | Tasks |
|------|-------------|-------|
| src/config/default-config.json | ADD field | T001 |
| src/hooks/common.sh | ADD loading | T002 |
| src/hooks/post_run_command.sh | MODIFY | T004, T005, T007 |
| tests/unit/test_git_notify.bats | NEW | T003, T006 |
| README.md | UPDATE | T008 |

---

## Task Summary

| Phase | Task Count | Parallel Tasks |
|-------|------------|----------------|
| Setup | 2 | 2 |
| US1 (P1) | 3 | 1 |
| US2 (P2) | 2 | 1 |
| Polish | 3 | 2 |
| **Total** | **10** | **6** |
