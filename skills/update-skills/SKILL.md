---
name: update-skills
description: "Update installed agent skills in the current environment (global or project-local) from their upstream repos and lockfiles. Use when asked to update skills or check for newer skill versions."
---

# Update Skills

## 1. Inventory the environment

Pick scope from the prompt: **global** (default) or **project-local**.

Scan whichever skill directories exist in the active environment:
- **Global**: `~/.agents/skills`, `~/.gemini/config/skills`, `~/.claude/skills`, `~/.opencode/skills`, `~/.cursor/skills`, `~/.codex/skills`, plus any OS mirror (e.g., `/mnt/c/Users/<user>/.agents/skills` when in WSL) and any local sync script (e.g., `~/.opencode/update-skills.sh`) that defines custom copies.
- **Project-local**: `.agents/skills`, `.claude/skills`, `.cursor/skills`, `.gemini/skills`.

Classify every skill root into one bucket:
1. **Git-backed**: follow symlinks to their enclosing `.git` root (plus source dirs like `~/.agents/sources/*`, `~/.opencode/repos/*`, `~/.gemini/config/plugins/*`); deduplicate by git root.
2. **Lockfile-managed**: governed by a `.skill-lock.json` in scope.
3. **Synced copy**: non-symlinked folder mirrored from a discovered git source.
4. **Local**: untracked folder with no upstream repo or lockfile; leave untouched.

**Done when** every skill root in scope is assigned to a bucket.

## 2. Pull git-backed sources

For each unique git repo:
1. Check `git status --porcelain`. Leave dirty or diverged repos untouched and record their status.
2. On clean repos, run `git fetch --quiet`, record `before` (`git rev-parse --short HEAD`) and `behind` (`git rev-list --count HEAD..@{u}`), then fast-forward with `git pull --ff-only`.
3. Re-sync any **synced copy** directories from their updated git source.

**Done when** every clean git repo is fast-forwarded, all synced copies are refreshed, and every dirty/diverged repo is logged.

## 3. Update lockfiles

For each `.skill-lock.json` in scope, run `npx -y skills@latest update -g -y` (global, in that lockfile's OS/shell) or `npx -y skills@latest update -y` (project-local).

**Done when** every lockfile in scope has been checked and its output recorded.

## 4. Repair and link symlinks

Across every active skill directory in scope:
1. Find dangling symlinks (`find -L <dir> -maxdepth 1 -type l`). Re-link moved skills to their new path in the source repo; remove links whose target was deleted upstream and log them.
2. In updated dedicated skill repos, link newly added `SKILL.md` directories into the active skill directories. In general-purpose monorepos where only a subset is opted in, list new skills in the report for the user to choose.

**Done when** `0` dangling symlinks remain across all active skill directories in scope.

## 5. Report

Render one summary table:

| Source | Method | Result | Notes |
| :--- | :--- | :--- | :--- |
| `repo-name` | git | `abc1234 → def5678` (4 new) | Linked `new-skill` |
| `skills-cli` | lockfile | Updated 3 skill(s) | Global |
| `custom-skill` | local | Skipped | Untracked local skill |

Follow with concise bullets for newly linked skills, repaired/removed links, skipped dirty repos, or manual follow-ups.
