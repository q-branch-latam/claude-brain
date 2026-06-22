# Contributing to the Q Branch LATAM brain

Knowledge flows **personal brain → team brain**, through a quality gate. You don't hand-edit this
repo's `docs/` directly — you promote a guide from your own brain with `/capture-to-team`, and the
command does the rest.

## The flow

1. **Gather (in your own brain).** During real project work, when you hit a gotcha that took retries,
   a prompt that finally worked, or a tooling quirk — run **`/capture`**. It proposes an entry; you
   approve/edit/reject; it commits to your **personal** brain with a why-rich message.

2. **Promote (to this repo).** When a guide is good enough to help a teammate, run **`/capture-to-team`**:
   - It picks the guide(s) and runs an **Opus review pass** — judging **clarity, self-containment,
     accuracy, and durability** (NOT security; this repo is public by design, internal identifiers are fine).
   - It shows you the verdict (`APPROVED` / `NEEDS_EDIT` / `KEEP_PERSONAL`) + rationale.
   - On your approval it writes the guide here, reconciles `INDEX.md`, and either commits to `main`
     (if you have write access) or opens a `promote/<guide>` PR (if you don't).
   - The commit/PR body quotes the Opus verdict, so the git history records *why* the guide was shared.

3. **Review (maintainers).** PRs are reviewed for the same four dimensions before merge. Maintainers
   can commit directly but are encouraged to let the Opus gate run anyway.

## Guide conventions

- **One topic per guide.** Guides are **living** — when a related lesson arrives, append/merge into the
  closest existing guide rather than spawning a near-duplicate. Edit in place when superseding; don't
  append contradictions.
- **Front-matter is required:** `name`, `description` (1–5 line summary of the whole file), `last_verified`,
  `authored_with`, `last_verified_with`, `tags`. New guides start from `docs/_TEMPLATE.md`.
- **`INDEX.md` stays in sync.** Every guide has exactly one one-liner trigger here; it's a faithful
  subset of the front-matter `description`, not a verbatim copy. `/capture-to-team` reconciles it.
- **Model attribution matters.** `authored_with` / `last_verified_with` record which model produced or
  last verified a guide — it helps the next reader judge how much to trust it and whether to re-verify.

## Branch / commit conventions

- Promotion branches: `promote/<guide-name>`.
- Commit subject: `promote(<guide>): <one-line summary>` (≤72 chars).
- Commit body: the Opus verdict + rationale, and the *why* (what we were doing when we learned this).

## What does NOT belong here

- **Personal facts** — your org table, profile, per-project status, machine paths. Those stay in your
  local workspace `CLAUDE.md` / native memory.
- **Live secrets** — access tokens, `frontdoor.jsp?otp=` URLs, session IDs, passwords to real/customer
  systems. (The shared `orgfarm1234` demo-trial password is the one tolerated exception, since it's
  public knowledge among SEs and unlocks nothing sensitive.)
- **One-off trivia** — anything git or the project's own `build-log.md` already records.

## Getting write access

Ask a maintainer to add you to the `q-branch-latam` org. Until then, `/capture-to-team` will open a PR
for you automatically — that path needs no special access beyond a fork/branch push.
