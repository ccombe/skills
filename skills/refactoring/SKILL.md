---
name: refactoring
description: "Behaviour-preserving refactoring: subtract first, lock untested code with a characterisation test, then micro-step under a green suite. Use when asked to refactor, clean up bloated, duplicated, or scattered code, or untangle untested legacy code."
---

# Refactoring

Change structure, preserve behaviour, leave it smaller.

## Separate hats

Wear one hat per pass:

- **Feature hat** — add capability; leave structure as it is.
- **Refactoring hat** — move structure; keep behaviour fixed:
  - public signatures, exported types, arity
  - error types and when they are thrown
  - observable side effects (writes, network calls, emitted events, parsed log lines) and their order
  - serialised shapes (payloads, files, DB rows, cache keys)
  - everything existing tests assert

When a request mixes both, land the feature first, then switch to the refactoring hat in a separate pass. Announce the switch.

## Step 0 — Baseline

Rebase onto clean trunk and run the test suite before editing. Record every pre-existing failure and the baseline pass count so regressions are distinguishable from existing noise.

**Done when** pre-existing failures and the baseline pass count are recorded.

## Step 1 — Subtract first

Default to deletion: remove dead branches, speculative guards, one-caller wrappers, one-implementation interfaces, unused parameters, and redundant comments before rearranging anything. Grep every reader (including re-exports and string references) before deleting.

**Done when** unused code in scope is deleted and the suite matches the Step 0 baseline.

## Step 2 — Lock untested code with one characterisation test

Skip if the code you are changing is already covered by behavioural tests.

Write one test that fails if you break what you are about to move:

1. **Find a seam** (a parameter, injectable dependency, or pure inner function).
2. **Probe it** with ordinary inputs, edge cases, and null/empty inputs; record outputs and observable side effects.
3. **Lock it** as assertions on observed behaviour (avoid asserting internal implementation details).
4. **Prove the test bites**: break the behaviour briefly, watch it go red, then restore it.

If no practical test path exists (live service or prod-only state), write a repeatable verification script and state the thinner safety net in the handback. If a characterisation test exposes a crash or defect, keep it, name the defect in the test name, and fix it in a separate feature-hat step.

**Done when** the test passes on unmodified code and has been observed failing when behaviour is intentionally broken.

## Step 3 — Untested code: sprout or wrap

When adding to legacy code you have only just brought under a seam:

- **Sprout**: write new logic in its own tested function or class, called from a single line in the legacy method.
- **Wrap**: rename the existing function and call both old and new logic from a wrapper keeping the original name.

**Done when** each sprout or wrap has its own passing test in its own commit.

## Step 4 — Covered code: green micro-steps

Consult [`SMELLS.md`](SMELLS.md) for the transformation matching the smell in front of you.

Apply one transformation at a time: run the narrowest loop that catches regressions, then commit. On red, revert to the last commit (fix any discovered defect in its own feature-hat step; if you believe the code is right, check whether a test was asserting implementation detail). Run the full suite before finishing.

**Done when** every transformation is an individually revertable commit, the full suite matches the Step 0 pass rate, and a reader can trace where state comes from and what mutates it in under 30 seconds.

## Step 5 — Prevent regression

For each removed smell, enforce the fix at the highest level that fits:

1. **Architecture**: give state one owner, hide internals so the wrong import fails to compile, delete the old pattern.
2. **Types**: narrow types so the bad shape fails typecheck.
3. **Lint or CI check**: fail with a message naming the replacement; for widespread legacy patterns, gate only newly added occurrences.
4. **Test**: fail if the pattern returns.
5. **Written rule**: only for judgement calls nothing can enforce.

Verify each new guard fails on a real instance of the smell before keeping it.

**Done when** every removed smell has an enforcement guard above it, or the reason a lower ceiling applies is stated.

## Step 6 — Stop at scope

Stop once the named smell is gone or the next move would expand into files outside the request. For a load-bearing or wide-diff refactor, run an independent review pass (a fresh subagent or reviewer) tasked with trying to prove behaviour changed.

## Handback

Report concisely:

- **Hat**: which hat(s) were worn and where any split occurred.
- **Baseline**: Step 0 pre-existing failures vs. final suite counts.
- **Steps**: commits made, one transformation each.
- **Deleted**: what was removed and how zero remaining readers were verified.
- **Enforced**: each removed smell and the guard preventing its return.
- **Smells / Defects left**: named with `file:line`, plus one-line next step if scope expands.
