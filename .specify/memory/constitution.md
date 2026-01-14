<!--
SYNC IMPACT REPORT
==================
Version change: 0.0.0 → 1.0.0 (initial ratification)
Modified principles: N/A (initial)
Added sections:
  - I. Behavior-Driven Development (BDD)
  - II. Production Environment Verification
  - Quality Gates
  - Governance
Removed sections: All template placeholders replaced
Templates requiring updates:
  - .specify/templates/spec-template.md ✅ (already aligned with BDD via Given/When/Then)
  - .specify/templates/plan-template.md ✅ (Constitution Check section compatible)
  - .specify/templates/tasks-template.md ✅ (test-first workflow compatible)
Follow-up TODOs: None
-->

# Windsurf Cascade Notifier Constitution

## Core Principles

### I. Behavior-Driven Development (BDD) (NON-NEGOTIABLE)

All features MUST be specified and implemented using Behavior-Driven Development practices:

- **Specification by Example**: Every feature MUST have acceptance criteria written in Given/When/Then format before implementation begins
- **Ubiquitous Language**: Scenarios MUST use domain language that stakeholders, developers, and tests all share
- **Living Documentation**: BDD scenarios serve as executable specifications; code MUST satisfy these scenarios exactly
- **Outside-In Development**: Start from user behavior, derive technical implementation—never the reverse

**Rationale**: BDD ensures alignment between stakeholder expectations and delivered functionality. Scenarios written in natural language prevent misunderstandings and provide verifiable acceptance criteria.

### II. Production Environment Verification (NON-NEGOTIABLE)

Delivery is verified ONLY when tests pass in production/real environment:

- **Real Environment Testing**: Acceptance tests MUST execute against production or production-equivalent environment to confirm delivery
- **No Mock-Only Validation**: Unit tests and mocked integrations are necessary but NOT sufficient for delivery sign-off
- **Smoke Tests on Deploy**: Every deployment MUST include automated smoke tests that validate core user journeys in the real environment
- **Observability Required**: Production tests MUST have logging/tracing to diagnose failures without reproduction locally

**Rationale**: Features that pass in isolated test environments but fail in production deliver zero value. Real environment verification is the only trustworthy signal that a feature works for users.

## Quality Gates

All deliverables MUST pass these gates before being considered complete:

1. **BDD Scenarios Defined**: Acceptance criteria exist in Given/When/Then format
2. **Scenarios Executable**: Automated tests implement all acceptance scenarios
3. **Local Tests Pass**: All tests pass in development environment
4. **Production Tests Pass**: Acceptance tests pass in production/real environment
5. **Stakeholder Sign-off**: Feature behavior matches scenario expectations

## Governance

- This constitution supersedes all other development practices in this project
- Amendments require: documented rationale, version increment, updated templates if affected
- All code reviews MUST verify compliance with both principles
- Exceptions require explicit justification documented in the PR/commit

**Version**: 1.0.0 | **Ratified**: 2026-01-14 | **Last Amended**: 2026-01-14
