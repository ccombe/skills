---
name: pr-board
description: "PR board: live status table for concurrent GitHub PRs. Use when orchestrating multiple open PRs, or when asked for a PR status overview."
---

# PR Board

## 1. Scope

Identify the target repository (current repo via `gh repo view`, or `--repo owner/name` when specified) and which PRs are in scope: the explicit PR numbers/branch prefix from the discussion, or all open PRs in that repo.

## 2. Fetch live state

Run one `gh api graphql` call so every cell reflects current GitHub state:

```bash
read -r OWNER REPO < <(gh repo view --json owner,name --jq '"\(.owner.login) \(.name)"')
gh api graphql -f owner="$OWNER" -f repo="$REPO" -f query='
query($owner: String!, $repo: String!) {
  repository(owner: $owner, name: $repo) {
    pullRequests(states: OPEN, first: 30, orderBy: {field: UPDATED_AT, direction: DESC}) {
      nodes {
        number url title isDraft reviewDecision mergeable
        reviewThreads(first: 100) { nodes { isResolved isOutdated } }
        commits(last: 1) {
          nodes { commit { statusCheckRollup {
            state
            contexts(first: 100) { nodes {
              ... on CheckRun { name conclusion status }
              ... on StatusContext { context state }
            } }
          } } }
        }
      }
    }
  }
}'
```

Filter `nodes` to the in-scope PR numbers when scoped to a subset.

## 3. Render the board

Use this exact column order on every render so recurring updates stay aligned:

| PR | Description | Approval | Comments | Merge Conflicts | GitHub Actions |
| :--- | :--- | :--- | :--- | :--- | :--- |
| [#142](https://github.com/owner/repo/pull/142) | Add token refresh middleware | Approved | Clear | None | Green |
| [#145](https://github.com/owner/repo/pull/145) | Migrate billing webhooks to v2 | Changes requested | 3 open | Conflicting | Failing (lint, test) |

### Column mapping

- **PR**: `[#<number>](<url>)`; append `(Draft)` when `isDraft` is true.
- **Description**: Plain 5–10 word summary of what the PR changes.
- **Approval** (`reviewDecision`): `Approved` (`APPROVED`) · `Changes requested` (`CHANGES_REQUESTED`) · `Review pending` (`REVIEW_REQUIRED` or `null`).
- **Comments** (`reviewThreads` where `isResolved == false && isOutdated == false`): `Clear` (0) · `<N> open`.
- **Merge Conflicts** (`mergeable`): `None` (`MERGEABLE`) · `Conflicting` (`CONFLICTING`) · `Checking…` (`UNKNOWN`).
- **GitHub Actions** (`statusCheckRollup.state`): `Green` (`SUCCESS`) · `Pending` (`PENDING`/`EXPECTED`) · `Failing (<2–3 names>)` (`FAILURE`/`ERROR`) · `None` (no checks).

Done when every in-scope PR is accounted for in the board, followed by 1–3 concise bullets naming what is ready to merge and what is blocked.

## 4. Keep the board live

During an ongoing multi-PR discussion, re-fetch and re-render the full board after any push, review, rebase, or merge, or when asked for an update.
