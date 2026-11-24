# ccombe/skills

Personal collection of portable agent skills.

## Skills

| Skill | Description |
| :--- | :--- |
| [`pr-board`](skills/pr-board/SKILL.md) | Live status table for concurrent GitHub PRs (clickable ID, description, approval, unresolved comments, merge conflicts, GitHub Actions). |
| [`refactoring`](skills/refactoring/SKILL.md) | Behaviour-preserving refactoring: subtract first, lock untested code with a characterisation test, then micro-step under a green suite. |
| [`transcribe-video`](skills/transcribe-video/SKILL.md) | Extract audio (chunked when >35 min) and write an executive summary + verbatim transcript beside any video or audio recording. |
| [`update-skills`](skills/update-skills/SKILL.md) | Environment-aware skill updater: discovers git-backed skill repos, lockfiles, and symlinks, pulls upstream updates, repairs broken links, and reports changes. |

## Install

```bash
npx skills add ccombe/skills
```

Or clone and symlink `skills/<name>` into your global skills directory (`~/.agents/skills/`, `~/.gemini/config/skills/`, or `~/.claude/skills/`).
