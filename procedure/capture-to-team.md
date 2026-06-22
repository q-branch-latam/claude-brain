# Procedure: capture-to-team (promote knowledge to the team)

Source of truth for the `/capture-to-team` slash command (`config/commands/capture-to-team.md`).
The command file is the executable spec; this doc explains the *why* and the rules a human should know.

## Goal

Move a durable guide from a person's **private** brain into the **public** team brain
(`q-branch-latam/claude-brain`) so the whole team benefits — but only after a quality gate confirms
the guide will actually be useful to a teammate who wasn't in the original session.

This is the second half of the federated model (see `procedure/sharing.md`):

```
/capture          → personal private brain     (gathering — solo, fast, approval-gated)
/capture-to-team  → public team brain via Opus gate + PR/commit  (sharing — curated, reviewed)
```

## Why an Opus gate, and why it is NOT a security pass

The team repo is **public by deliberate decision** — Q Branch are demo engineers, there is no client
data and no secrets in these guides, and a frictionless public repo is worth more to the team than
keeping internal-SF identifiers (colleague names, internal Slack channels, the shared `orgfarm1234`
workshop password) out of search indexes. So the gate does **not** sanitize or strip anything.

What it *does* check is **transfer quality**: a guide that made perfect sense to its author can be
useless to a teammate because it silently assumed context. Opus (a stronger model) reads the guide
cold and judges: self-contained, clear, accurate/not-stale, durable-vs-trivia. This is the
"double-check the knowledge with a stronger model before it goes to the team" step the user asked for.

## The four verdict dimensions

1. **Self-contained** — actionable without the author's missing context.
2. **Clear** — organized, unambiguous, scannable.
3. **Accurate / not stale** — steps look correct and current (flag a `last_verified` that's gone cold).
4. **Durable** — teachable knowledge, not one-off session trivia.

Verdict is one of `APPROVED` / `NEEDS_EDIT` / `KEEP_PERSONAL` + a one-paragraph rationale.

## Direct-commit vs PR (auto-detected)

The command checks `viewerPermission` on the team repo:
- **Maintainers (Gonzalo & co.)** commit straight to `main` — they own the canonical guides.
- **Teammates without write** open a `promote/<guide>` PR — reviewable before merge.

Either way the commit message carries the Opus verdict + rationale, so the team repo's git history
records *why* each guide was deemed shareable — the same "history is a knowledge layer" principle the
personal brain uses.

## Model attribution on promotion

When a guide is promoted, `last_verified` is bumped to today and `last_verified_with` is set to
`claude-opus-4-8` (Opus ran the gate). `authored_with` is preserved — it records who originally wrote it.

## Invariants

- **Never auto-promote.** Opus advises; the human approves every push/PR.
- **No sanitization.** Internal identifiers stay — the repo is public on purpose.
- **Pull before push.** Always refresh the team clone to avoid stale-base conflicts.
- **INDEX stays in sync** in the team repo (one-liner trigger per guide).
- **Personal → team only.** Pulling team knowledge back into a personal brain is manual (read team
  `INDEX.md`, copy what's relevant) — see `procedure/sharing.md`.
