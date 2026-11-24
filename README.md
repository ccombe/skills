# ccombe/skills

Personal collection of portable agent skills, plus an index of upstream skill packs used across machines.

## Personal Skills

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

## Skill Packs (New Machine Setup)

All upstream skill repositories used alongside this collection:

| Name | Repository | What it offers |
| :--- | :--- | :--- |
| **ccombe/skills** | https://github.com/ccombe/skills | Personal portable skills (`pr-board`, `refactoring`, `transcribe-video`, `update-skills`). |
| **pstack & cursor-team-kit** | https://github.com/cursor/plugins | Rigorous engineering workflows (`pstack`: `architect`, `arena`, `statechart`, `unslop`, `sharpen`, `ketchup`, formal verification, engineering principles) plus Cursor team utilities (`deslop`, `fix-ci`, `fix-merge-conflicts`). |
| **Matt Pocock Skills** | https://github.com/mattpocock/skills | Engineering and writing skills (`tdd`, `grill-me`, `writing-for-agents`, `code-review`, `diagnosing-bugs`, `domain-modeling`, `codebase-design`, `prototype`, `to-spec`, `to-tickets`, `wizard`). |
| **Compound Engineering** | https://github.com/everyinc/compound-engineering-plugin | Full-lifecycle `ce-*` workflows (`ce-brainstorm`, `ce-plan`, `ce-work`, `ce-code-review`, `ce-babysit-pr`, `ce-compound`, `ce-debug`, `ce-optimize`, `ce-noslop`). |
| **Anthropic Skills** | https://github.com/anthropics/skills | Official Anthropic skills (`frontend-design`, `canvas-design`, `mcp-builder`, `docx`, `doc-coauthoring`, `brand-guidelines`, `claude-api`). |
| **HumanLayer Skills** | https://github.com/humanlayer/skills | Research-Plan-Implement (`rpi`), `design-control-loop`, `build-iterated-agentic-loop`, and `CLAUDE.md` improvement workflows. |
| **Ponytail** | https://github.com/dietrichgebert/ponytail | Minimalist senior-dev coding mode (`ponytail`, `ponytail-review`, `ponytail-audit`, `ponytail-debt`) to prevent over-engineering and bloat. |
| **Fallow Skills** | https://github.com/fallow-rs/fallow-skills | Codebase health, dead-code, duplication, complexity, boundary, and mutation-testing skills for TypeScript/JavaScript (`fallow`, `fallow-review`, `fallow-mutation`, `fallow-setup`) and Rust (`cargo-fallow`). |
| **Bombadil Skills** | https://github.com/unhinged-mochi/bombadil-skills | Property-based testing and autonomous fuzzing for web apps (`bombadil-browser`) and CLIs/TUIs (`bombadil-terminal`) with Antithesis Bombadil. |
| **Cloudflare Security Audit** | https://github.com/cloudflare/security-audit-skill | Structured security review and vulnerability-hunting methodology (`security-audit`) across auth, web protocols, cloud, supply chain, and AI/LLM surfaces. |
| **Gridlines** | https://github.com/pritamux/gridlines | UI alignment and optical spacing audit skill (`gridlines`) for sidebars, toolbars, panels, dialogs, and tables. |
| **Neon Agent Skills** | https://github.com/neondatabase/agent-skills | Lakebase Postgres and Neon platform skills (`neon`, `neon-postgres`, `neon-auth`, `neon-functions`, `neon-object-storage`, `neon-realtime`, `neon-ai-gateway`). |
| **Microsoft Azure Skills** | https://github.com/microsoft/azure-skills | Microsoft Foundry and Azure agent development, evaluation, fine-tuning, and deployment (`microsoft-foundry`). |
| **OpenClaw** | https://github.com/openclaw/openclaw | Selective skills from OpenClaw (e.g., `test-audit`). |
| **Vercel Skills CLI** | https://github.com/vercel-labs/skills | Skill discovery helper (`find-skills`) and the `npx skills` CLI installer/updater. |
