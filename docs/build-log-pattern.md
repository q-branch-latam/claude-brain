---
name: Build-Log Pattern (Layer 2 — the running narrative)
description: >-
  The per-project "Present" layer of the Context Stack: an append-only,
  timestamped build-log.md that the AI maintains AUTONOMOUSLY (no approval gate)
  on milestone triggers — phase done, non-obvious fix, before /compact, decision
  reversal. Captures dead ends, surprise field names, and "where we left off" so a
  new session or a post-compact session reloads the whole arc in one read. Includes
  the drop-in trigger-rule block for a project CLAUDE.md, what to log vs. skip, and
  how it differs from /capture (durable, shared, approval-gated) and from git.
last_verified: 2026-06-21
tags: [context-stack, build-log, workflow, compaction, per-project, layer-2]
authored_with: claude-sonnet-4-6
last_verified_with: claude-sonnet-4-6
---

# Build-Log Pattern (Layer 2 — the running narrative)

Open this when: setting up a project's working-memory log, deciding what belongs in `build-log.md` vs. the brain, or wiring the autonomous trigger rules into a project `CLAUDE.md`.

## Where this fits — the Context Stack

A project teaches its own context to the AI across four layers, each answering a different question over a different time horizon:

| Layer | Time | File / source | Question | Who maintains it |
|---|---|---|---|---|
| 0 Awareness | Always, everywhere | global `~/.claude/CLAUDE.md` | "Does this conversation even use the procedure?" | you (set once) |
| 1 Past | Settled history | `git log` / `git diff` | "What changed at the line level, and why?" | AI writes commit msgs |
| **2 Present** | **In-progress** | **`build-log.md`** | **"What's the running story, where are we?"** | **AI, autonomously (this guide)** |
| 3 Always-true | Durable, shared | `claude-brain/docs/*.md` via `/capture` | "How does this work, what did we learn?" | AI, **approval-gated** |

Layer 2 is the gap most setups miss. Git tells you what changed; the brain tells you what's always true; **the build-log tells you what's happening right now** — the dead ends, the field that turned out to be named something unexpected, the workaround you'll forget by Thursday, and exactly where you stopped. Point a fresh (or post-`/compact`) session at it and the whole arc loads in one read instead of being reconstructed from history.

## The file

`build-log.md` lives at the **project root** (next to the project's `CLAUDE.md`). Append-only, newest entries at the bottom, timestamped. One project = one log.

```markdown
# Build Log — <Project Name>

> Append-only running narrative (Context-Stack Layer 2). Newest at the bottom.
> The AI updates this autonomously on the triggers in CLAUDE.md — no need to ask.
> Durable, teachable gotchas get promoted to the shared brain via /capture; this
> log is the project-local story, including the messy parts.

## 2026-06-21
- **[milestone]** Phase 2 metadata authored + deployed to `<alias>` (first-try green).
- **[gotcha]** `Refund__c.Status__c` picklist API value is `Processed`, not `Complete` —
  deploy failed twice on the wrong value. (Candidate for /capture if it recurs.)
- **[decision]** Dropped the GraphQL data path; using Apex REST proxy (guest-gated). Why: 401 on Experience surface.
- **[next]** Wire the agent action to `Get_Refund_Status`; left off mid-flow-build.
```

Keep entries terse — bullets, not prose. Tag them so they're scannable: `[milestone]`, `[gotcha]`, `[decision]`, `[blocker]`, `[next]`.

Optionally tag the **model** that produced a non-obvious fix or key decision — this helps gauge how trustable the knowledge is and whether re-verification with a newer model is warranted:

```markdown
- 2026-06-22 [fix][model: sonnet-4-6] OrgFarm MFA code arrives in Slack #orgfarm-orgs-mfa-codes, not by email.
- 2026-06-22 [decision][model: opus-4-8] Chose Apex REST proxy over GraphQL for guest data access on Experience surface.
```

Use `[model: <id>]` only on bullets where the model's reasoning was load-bearing (a judgment call, a multi-retry fix, a design decision). Skip it on routine "deployed successfully" entries.

## The autonomous trigger block (paste into a project CLAUDE.md)

This is the load-bearing move: the AI updates the log **without being asked**, so you stay in flow. Unlike `/capture` (which is always approve-before-write because it edits *shared* knowledge), the build-log is *project-local, low-stakes working memory* — autonomy is correct here.

```markdown
## Build log (Context-Stack Layer 2 — keep it current, autonomously)

This project has a `build-log.md` at its root: the append-only running narrative.
**Maintain it yourself, without asking,** by appending a short timestamped bullet when ANY of these fire:
- a phase / milestone completes, or a deploy goes green;
- a non-obvious fix lands (something that took more than one try, or a surprise like an unexpected field name);
- a decision or its reversal (chose X over Y, and why);
- a blocker is hit (what's blocked, what's needed to unblock);
- **immediately before running `/compact`** — write a `[next]` bullet capturing exactly where we are, so the post-compact session resumes cold.
Rules: append-only, newest at the bottom, terse bullets with a `[tag]`. Do NOT rewrite history.
Do NOT put live secrets/tokens here. If a logged gotcha is durable + teachable (would help a teammate
or a future project), flag it as a `/capture` candidate — the brain is the shared layer; this log is local.
```

## What to log vs. what to skip

**Log:** milestones, deploy results, non-obvious fixes, decisions + reversals, blockers, "where we left off." The messy in-progress reality.

**Skip:** routine reads/searches, every file edit (git already has those), restating what the diff shows, anything that's just noise. The log is a *narrative of decision points*, not a keystroke recorder.

## Relationship to the other layers (don't duplicate)

- **vs. git (Layer 1):** git has the exact line-level *what*. The log has the *story and the dead ends* — including paths that left no commit because they were abandoned. Don't paste diffs into the log; reference a commit sha if useful.
- **vs. the brain (Layer 3) / `/capture`:** the log is project-local and autonomous; the brain is shared, durable, and approval-gated. The flow is **log → (if durable) promote to a brain guide via `/capture`**. A gotcha can live in the log first; if it recurs or generalizes, `/capture` lifts it into `docs/`. Never inline-edit the brain from the build-log without going through `/capture`.

## Migrating existing ad-hoc analogs

Older projects already improvised this layer under other names — fold them into `build-log.md` going forward (leave the originals in place; no erasing):
- `docs/COMPRESSION_phaseN_to_phaseN+1.md` (Automotive-Workshop) — pre-compact handoff briefs.
- `HANDOFF.md` (RTCCO), `SESSION_HANDOFF_*.md` (comfandi) — "where we left off" snapshots.

These were the build-log in spirit; the pattern just standardizes the name, the triggers, and the autonomy.

## Why (the part the diff can't show)

This layer was the one piece of Bera Aksoy's "Context Stack" missing from the first claude-brain build (which shipped Layers 1 + 3 + the cross-project catalog). The insight: settled knowledge (git + brain) isn't enough — an in-progress build accumulates *transient* context that's worthless to formalize but expensive to lose. Making the AI maintain it on triggers, autonomously, is what keeps the human in flow and makes `/compact` safe instead of lossy.

## References

- The Context Stack (Bera Aksoy, AFD360 L3 build week) — the three-layer model + "now multiply it" catalog idea.
- `/capture` + the durable layer → `procedure/capture.md`, this repo's `CLAUDE.md`.
- New-project scaffolding that drops this in automatically → the `/bootstrap-project` command (`config/commands/bootstrap-project.md`).
