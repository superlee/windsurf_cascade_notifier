# Tasks: Hooks.json Install/Uninstall Management

**Input**: Design documents from `/specs/003-hooks-json-install/`
**Prerequisites**: plan.md ✅, spec.md ✅, research.md ✅, quickstart.md ✅

**Tests**: BATS tests included per constitution principle I (BDD)

**Organization**: Tasks grouped by user story for independent implementation and testing.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (US1, US2)
- Exact file paths included in descriptions

---

## Phase 1: Setup

**Purpose**: Create shared library for hooks.json manipulation

- [x] T001 Create hooks_manager.sh with shared functions in src/lib/hooks_manager.sh
- [x] T002 [P] Add backup_hooks_json() function to src/lib/hooks_manager.sh
- [x] T003 Add merge_hooks() function to src/lib/hooks_manager.sh
- [x] T004 Add remove_notifier_hooks() function to src/lib/hooks_manager.sh

---

## Phase 2: User Story 1 - Auto-configure User-Level Hooks on Install (Priority: P1) 🎯 MVP

**Goal**: Install creates/updates `~/.codeium/windsurf/hooks.json` with notifier hooks

**Independent Test**: Run `./install.sh`, verify hooks.json contains notifier entries

### Tests for User Story 1

- [x] T005 [P] [US1] Create BATS test for fresh install (no existing hooks.json) in tests/unit/test_hooks_manager.bats
- [x] T006 [P] [US1] Create BATS test for install with existing hooks in tests/unit/test_hooks_manager.bats
- [x] T007 [P] [US1] Create BATS test for idempotent install in tests/unit/test_hooks_manager.bats

### Implementation for User Story 1

- [x] T008 [US1] Update install.sh to source src/lib/hooks_manager.sh
- [x] T009 [US1] Add WINDSURF_HOOKS_FILE variable (~/.codeium/windsurf/hooks.json) to install.sh
- [x] T010 [US1] Add create parent directories logic to install.sh
- [x] T011 [US1] Add backup before modification logic to install.sh
- [x] T012 [US1] Add merge_hooks() call to install.sh
- [x] T013 [US1] Add project-level hooks.json warning to install.sh

**Checkpoint**: User Story 1 complete - install configures user-level hooks

---

## Phase 3: User Story 2 - Clean Uninstall of Hooks (Priority: P2)

**Goal**: Uninstall removes only notifier hooks, preserves others

**Independent Test**: Run `./uninstall.sh`, verify notifier hooks removed, other hooks preserved

### Tests for User Story 2

- [x] T014 [P] [US2] Create BATS test for uninstall removes notifier hooks in tests/unit/test_hooks_manager.bats
- [x] T015 [P] [US2] Create BATS test for uninstall preserves other hooks in tests/unit/test_hooks_manager.bats
- [x] T016 [P] [US2] Create BATS test for uninstall with missing hooks.json in tests/unit/test_hooks_manager.bats

### Implementation for User Story 2

- [x] T017 [US2] Update uninstall.sh to source src/lib/hooks_manager.sh
- [x] T018 [US2] Add WINDSURF_HOOKS_FILE variable to uninstall.sh
- [x] T019 [US2] Add backup before modification logic to uninstall.sh
- [x] T020 [US2] Add remove_notifier_hooks() call to uninstall.sh
- [x] T021 [US2] Update uninstall completion message with hooks.json status

**Checkpoint**: User Story 2 complete - uninstall cleans up hooks

---

## Phase 4: Polish & Cross-Cutting Concerns

**Purpose**: Documentation, edge cases, and validation

- [x] T022 [P] Add edge case handling for malformed JSON in src/lib/hooks_manager.sh
- [x] T023 [P] Add edge case handling for permission errors in src/lib/hooks_manager.sh
- [x] T024 [P] Update README.md with user-level hooks information
- [x] T025 Run quickstart.md validation (production environment test per constitution II)

---

## Dependencies & Execution Order

### Phase Dependencies

```
Phase 1 (Setup) - shared library
    ↓
Phase 2 (US1 - MVP) ← install works
    ↓
Phase 3 (US2) ← uninstall works
    ↓
Phase 4 (Polish)
```

### User Story Dependencies

| Story | Can Start After | Dependencies on Other Stories |
|-------|-----------------|-------------------------------|
| US1 (P1) | Phase 1 complete | None - fully independent |
| US2 (P2) | Phase 1 complete | Shares hooks_manager.sh with US1 |

### Within Each User Story

1. Tests MUST be written and FAIL before implementation (BDD)
2. Library functions before script integration
3. Story complete before moving to next priority

### Parallel Opportunities

**Phase 1**: T002 can run in parallel with T001 creation
**Phase 2**: T005, T006, T007 (tests) can run in parallel
**Phase 3**: T014, T015, T016 (tests) can run in parallel
**Phase 4**: T022, T023, T024 can run in parallel

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup (T001-T004)
2. Complete Phase 2: User Story 1 (T005-T013)
3. **STOP and VALIDATE**: Run quickstart.md Test 1-3
4. Deploy if ready - install configures user-level hooks!

### Incremental Delivery

| Milestone | Stories Complete | User Value |
|-----------|------------------|------------|
| MVP | US1 | Install auto-configures hooks.json |
| v1.1 | US1 + US2 | Clean uninstall removes hooks |
| v1.2 | All + Polish | Production-ready with edge cases |

### File Changes Summary

| File | Change Type | Tasks |
|------|-------------|-------|
| src/lib/hooks_manager.sh | NEW | T001-T004, T022-T023 |
| install.sh | MODIFY | T008-T013 |
| uninstall.sh | MODIFY | T017-T021 |
| tests/unit/test_hooks_manager.bats | NEW | T005-T007, T014-T016 |
| README.md | UPDATE | T024 |

---

## Task Summary

| Phase | Task Count | Parallel Tasks |
|-------|------------|----------------|
| Setup | 4 | 1 |
| US1 (P1) | 9 | 3 |
| US2 (P2) | 8 | 3 |
| Polish | 4 | 3 |
| **Total** | **25** | **10** |
