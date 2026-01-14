# Tasks: Cascade Blocked Notification

**Input**: Design documents from `/specs/001-cascade-blocked-notify/`
**Prerequisites**: plan.md ✅, spec.md ✅, research.md ✅, data-model.md ✅, contracts/ ✅

**Tests**: BDD-style tests using BATS framework (per constitution principle I)

**Organization**: Tasks grouped by user story for independent implementation and testing.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (US1, US2, US3)
- Exact file paths included in descriptions

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Project initialization and directory structure

- [x] T001 Create project directory structure per plan.md in src/hooks/, src/config/, src/lib/
- [x] T002 [P] Create default config.json template with sound_enabled option in src/config/default-config.json
- [x] T003 [P] Create README.md with project overview and installation instructions
- [x] T004 [P] Create .gitignore for logs and local config files

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core infrastructure that ALL user stories depend on

**⚠️ CRITICAL**: No user story work can begin until this phase is complete

- [x] T005 Implement common.sh with shared functions (logging, config loading) in src/hooks/common.sh
- [x] T005a Implement config loading function (load_preferences) in src/hooks/common.sh
- [x] T006 [P] Implement focus detection function (is_windsurf_focused) in src/lib/focus.sh
- [x] T007 [P] Implement JSON parsing wrapper (parse_hook_input) in src/lib/json_parser.sh
- [x] T008 Implement core notifier.sh with send_notification function (including sound via osascript 'sound name') in src/lib/notifier.sh
- [x] T008a [P] Implement click-to-focus function (activate_windsurf) in src/lib/focus.sh
- [x] T009 Implement debounce logic (check_debounce, update_debounce) in src/lib/debounce.sh
- [x] T010 Implement logging function (log_event) in src/lib/logger.sh
- [x] T011 Create install.sh script for user installation in install.sh

**Checkpoint**: Foundation ready - user story implementation can now begin

---

## Phase 3: User Story 1 - Terminal Password Prompt Notification (Priority: P1) 🎯 MVP

**Goal**: Notify user when Cascade is blocked waiting for terminal input (password prompts)

**Independent Test**: Run `sudo echo hello` via Cascade with Windsurf unfocused, verify notification appears

### Tests for User Story 1

- [x] T012 [P] [US1] Create BATS test for terminal blocking detection in tests/unit/test_terminal_detection.bats
- [x] T013 [P] [US1] Create BATS integration test for terminal notification in tests/integration/test_terminal_blocked.bats

### Implementation for User Story 1

- [x] T014 [US1] Implement post_run_command.sh hook entry point in src/hooks/post_run_command.sh
- [x] T015 [US1] Add terminal input detection logic (detect patterns: Password:, passphrase, sudo) in src/hooks/post_run_command.sh
- [x] T016 [US1] Integrate focus check, debounce, and notification for terminal events in src/hooks/post_run_command.sh
- [x] T017 [US1] Add "Cascade blocked: Terminal waiting for input" notification message in src/hooks/post_run_command.sh

**Checkpoint**: User Story 1 complete - terminal blocking notifications functional

---

## Phase 4: User Story 2 - Task Completion Notification (Priority: P2)

**Goal**: Notify user when Cascade finishes a task (success or error)

**Independent Test**: Ask Cascade to create a file, verify notification appears when task completes

### Tests for User Story 2

- [x] T018 [P] [US2] Create BATS test for task completion detection in tests/unit/test_task_completion.bats
- [x] T019 [P] [US2] Create BATS integration test for task completion notification in tests/integration/test_task_complete.bats

### Implementation for User Story 2

- [x] T020 [US2] Implement post_cascade_response.sh hook entry point in src/hooks/post_cascade_response.sh
- [x] T021 [US2] Add task completion detection logic in src/hooks/post_cascade_response.sh
- [x] T022 [US2] Add error detection logic for "Task stopped - Error encountered" in src/hooks/post_cascade_response.sh
- [x] T023 [US2] Integrate focus check, debounce, and notification for task events in src/hooks/post_cascade_response.sh

**Checkpoint**: User Story 2 complete - task completion notifications functional

---

## Phase 5: User Story 3 - User Approval Required Notification (Priority: P3)

**Goal**: Notify user when Cascade is waiting for approval to run a command

**Independent Test**: Trigger a command requiring approval, verify notification appears after 10 seconds

### Tests for User Story 3

- [x] T024 [P] [US3] Create BATS test for approval detection in tests/unit/test_approval_detection.bats
- [x] T025 [P] [US3] Create BATS integration test for approval notification in tests/integration/test_approval_required.bats

### Implementation for User Story 3

- [x] T026 [US3] Add approval-waiting detection to post_cascade_response.sh in src/hooks/post_cascade_response.sh
- [x] T027 [US3] Implement 10-second delay check for approval prompts in src/hooks/post_cascade_response.sh
- [x] T028 [US3] Add "Cascade: Waiting for your approval" notification message in src/hooks/post_cascade_response.sh

**Checkpoint**: User Story 3 complete - approval notifications functional

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: Improvements that affect multiple user stories

- [x] T029 [P] Create hooks.json configuration file for Windsurf in src/config/hooks.json
- [x] T030 [P] Update README.md with full usage documentation in README.md
- [x] T031 [P] Add configuration options documentation in README.md
- [x] T031a Add hot-reload config support (re-read config on each hook invocation) in src/hooks/common.sh
- [x] T032 Run quickstart.md validation (production environment test per constitution II)
- [x] T033 Code cleanup and shellcheck linting across all scripts
- [x] T034 [P] Create uninstall.sh script in uninstall.sh

---

## Dependencies & Execution Order

### Phase Dependencies

```
Phase 1 (Setup)
    ↓
Phase 2 (Foundational) ← BLOCKS all user stories
    ↓
Phase 3 (US1) ─┬─ Phase 4 (US2) ─┬─ Phase 5 (US3)
               │                  │
               └──────────────────┴──→ Phase 6 (Polish)
```

### User Story Dependencies

| Story | Can Start After | Dependencies on Other Stories |
|-------|-----------------|-------------------------------|
| US1 (P1) | Phase 2 complete | None - fully independent |
| US2 (P2) | Phase 2 complete | None - fully independent |
| US3 (P3) | Phase 2 complete | Shares post_cascade_response.sh with US2 |

### Within Each User Story

1. Tests MUST be written and FAIL before implementation
2. Hook entry point before detection logic
3. Detection logic before notification integration
4. Story complete before moving to next priority

### Parallel Opportunities

**Phase 1**: T002, T003, T004 can run in parallel
**Phase 2**: T006, T007 can run in parallel; T009, T010 can run in parallel after T005
**Phase 3**: T012, T013 can run in parallel (tests)
**Phase 4**: T018, T019 can run in parallel (tests)
**Phase 5**: T024, T025 can run in parallel (tests)
**Phase 6**: T029, T030, T031, T034 can run in parallel

---

## Parallel Example: Phase 2 (Foundational)

```bash
# First wave (no dependencies):
Task T005: "Implement common.sh with shared functions in src/hooks/common.sh"
Task T006: "Implement focus detection function in src/lib/focus.sh" [P]
Task T007: "Implement JSON parsing wrapper in src/lib/json_parser.sh" [P]

# Second wave (depends on T005):
Task T008: "Implement core notifier.sh in src/lib/notifier.sh"
Task T009: "Implement debounce logic in src/lib/debounce.sh" [P]
Task T010: "Implement logging function in src/lib/logger.sh" [P]

# Third wave (depends on all above):
Task T011: "Create install.sh script in install.sh"
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup (T001-T004)
2. Complete Phase 2: Foundational (T005-T011) ← CRITICAL
3. Complete Phase 3: User Story 1 (T012-T017)
4. **STOP and VALIDATE**: Run quickstart.md Test 1
5. Deploy if ready - terminal notifications working!

### Incremental Delivery

| Milestone | Stories Complete | User Value |
|-----------|------------------|------------|
| MVP | US1 | Terminal blocking notifications |
| v1.1 | US1 + US2 | + Task completion notifications |
| v1.2 | US1 + US2 + US3 | + Approval notifications |
| v1.3 | All + Polish | Production-ready |

### File Ownership by Story

| File | Owner | Shared With |
|------|-------|-------------|
| src/hooks/post_run_command.sh | US1 | - |
| src/hooks/post_cascade_response.sh | US2 | US3 |
| src/lib/*.sh | Foundational | All stories |
| tests/integration/test_terminal_blocked.bats | US1 | - |
| tests/integration/test_task_complete.bats | US2 | - |
| tests/integration/test_approval_required.bats | US3 | - |

---

## Notes

- [P] tasks = different files, no dependencies
- [Story] label maps task to specific user story for traceability
- Each user story is independently testable per spec.md
- Verify tests FAIL before implementing (BDD per constitution I)
- Commit after each task or logical group
- Stop at any checkpoint to validate story independently
- US3 shares hook file with US2 - coordinate implementation

---

## Task Summary

| Phase | Task Count | Parallel Tasks |
|-------|------------|----------------|
| Setup | 4 | 3 |
| Foundational | 9 | 5 |
| US1 (P1) | 6 | 2 |
| US2 (P2) | 6 | 2 |
| US3 (P3) | 5 | 2 |
| Polish | 7 | 4 |
| **Total** | **37** | **18** |
