---
name: update-skills
description: "Discover and update all installed agent skills in the current environment (git-backed repos, skills CLI lockfiles, and symlinks) in one pass. Use when asked to update skills, sync skill libraries, or check for newer skill versions."
---

# Update Skills

Generic, environment-aware updater for installed agent skills. Discovers what is installed in the current context rather than assuming fixed paths or repos.

## 1. Discover the skill inventory

Determine scope from the prompt: **global** (default) or **project-local** (when asked to update a specific repo's skills).

Inspect whichever skill directories exist in the current environment:
- **Global**: `~/.agents/skills`, `~/.gemini/config/skills`, `~/.claude/skills`, `~/.opencode/skills`, `~/.cursor/skills`, `~/.codex/skills` (and any Windows mirror such as `/mnt/c/Users/<user>/.agents/skills` when running in WSL).
- **Project-local**: `.agents/skills`, `.claude/skills`, `.cursor/skills`, `.gemini/skills`.

Also check for any existing local sync script (e.g., `~/.opencode/update-skills.sh`) to spot custom non-symlinked copies or plugin caches that should be kept in sync.

Classify every installed skill root into one of four buckets:
1. **Git-backed repo**: follow symlinks to their enclosing `.git` root (plus any sibling source folders like `~/.agents/sources/*`, `~/.opencode/repos/*`, `~/.gemini/config/plugins/*`). Deduplicate by git root.
2. **Lockfile-managed**: governed by a `.skill-lock.json` (`~/.agents/.skill-lock.json`, Windows mirror lockfile, or project `.skill-lock.json`).
3. **Copied from a source repo**: non-symlinked directory that matches a discovered git source or custom sync rule.
4. **Local / untracked**: custom directory with no upstream repo or lockfile — leave untouched and list in the summary.

**Done when** every installed skill directory in scope is mapped to one of the four buckets.

## 2. Pull git-backed sources

For each unique git repo:
1. Check `git status --porcelain`. If dirty, record the modified files and skip destructive resets; only run `git pull --ff-only` if tracked edits do not conflict.
2. Run `git fetch --quiet`, record `before=$(git rev-parse --short HEAD)` and `behind=$(git rev-list --count HEAD..@{u})`, then run `git pull --ff-only`.
3. Record `before -> after (N new)` or `already current`.

Re-sync any discovered non-symlinked copies (e.g., plugin copies or OS mirrors) from their updated source repo.

**Done when** every clean git-backed source is fast-forwarded to upstream, copies are synced, and any dirty or diverged repo is logged with its reason.

## 3. Update lockfile-managed skills

For each discovered `.skill-lock.json` in scope:
- Global: run `npx -y skills@latest update -g -y` (in the corresponding OS/shell context for that lockfile).
- Project-local: run `npx -y skills@latest update -y` in the project root.

**Done when** every lockfile in scope has run its update check and output is captured.

## 4. Audit and repair symlinks

Across all active skill directories in scope:
1. **Broken symlinks**: locate every dangling symlink (`find -L <dir> -maxdepth 1 -type l`). If the skill moved inside its source repo (e.g., graduated from `in-progress/` to `engineering/`), re-link it to the new path; if removed upstream, delete the dangling link and note it.
2. **Newly added skills**: in updated dedicated skill repos, check for new `SKILL.md` directories not yet linked into the active skill directories and link them. For large general-purpose monorepos where only a subset of skills is opted in, list new skills for the user instead of auto-linking everything.

**Done when** `0` broken symlinks remain across all active skill directories in scope.

## 5. Report

Render a concise summary table:

| Source | Method | Result | Notes |
| :--- | :--- | :--- | :--- |
| `repo-name` | git | `abc1234 → def5678` (4 new) | Linked `new-skill` |
| `skills-cli` | lockfile | Updated 3 skill(s) | Global |
| `custom-skill` | local | Skipped | Untracked local skill |

Beneath the table, call out any newly linked skills, repaired/removed broken links, skipped dirty repos, or manual follow-ups.
