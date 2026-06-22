# Procedure: capture (knowledge gathering)

Source of truth for the `/capture` slash command (`config/commands/capture.md`). The command file is the executable spec; this doc explains the *why* and the rules a human should know.

## Goal

Turn what was learned in a session into durable, shareable knowledge — without bloating the always-loaded context layer, and without writing anything the user didn't approve.

## What counts as a durable learning (capture these)

- A gotcha that **took multiple retries** to resolve (deploy errors, metadata quirks, API/CLI surprises, env/tooling issues).
- A **non-obvious prompt or workflow** that worked where the obvious one failed.
- A **tooling/environment quirk** specific to this machine or these orgs.

## What to skip (do NOT capture)

- One-off task details, file paths specific to a single project, or anything the repo/git history already records.
- Generic best practices a competent engineer already knows.
- **Personal facts** — org tables, the user profile, per-project status. These belong in the workspace `CLAUDE.md` or native memory, NOT in `docs/`.

## The flow

1. **Review the session** for candidates against the criteria above.
2. **Classify each candidate:**
   - *Personal fact* → suggest it go to workspace `CLAUDE.md` / native memory (not this repo).
   - *Shareable gotcha* → destined for `docs/`. Decide: does it fit an **existing** guide (append/update) or need a **new** guide (from `docs/_TEMPLATE.md`)?
3. **Propose, don't write.** For each candidate present a short preview: target guide, the exact text to add/change, whether `INDEX.md` needs updating, and the **commit message** you'd use. The user picks **approve / edit / reject** per item.
4. **On approval, write:**
   - Edit the guide body. **Guides are living and grow** — when a learning is close to an existing guide's topic, append/merge it there rather than creating a near-duplicate. Edit in place if superseding an old lesson; don't append a contradiction.
   - **Bump `last_verified`** to today on every guide touched.
   - **Set `authored_with`** to the current model ID (e.g. `claude-sonnet-4-6`, `claude-opus-4-8`) on any guide newly created; set **`last_verified_with`** to the current model ID on any guide edited or verified.
   - Keep the guide's front-matter `description` accurate: it's a **1–5 line summary of the whole guide** (one line unless the guide's breadth needs more). Widen it if the scope grew.
   - **Reconcile the `INDEX.md` line** — a single one-liner trigger consistent with (but not identical to) the front-matter summary. Re-scan INDEX ↔ docs for drift.
   - Show the diff of everything written.
5. **Sanitize.** Never write live tokens, `frontdoor.jsp?otp=` URLs, session IDs, or passwords. Org usernames / internal channel names are acceptable (private repo) but keep them out of any guide that might later go public.
6. **Commit + push (the history layer).** After the user accepts the written changes, commit and push so the learning is durable and shareable, AND so the *why* is preserved in git history:
   - Stage only the touched files; one commit per coherent learning when practical.
   - **Message:** subject `capture(<guide>): <what was learned>` (≤72 chars); body explains **why** — what we were doing, what failed / how many retries, root cause, what worked, confidence. This is what a teammate (or a future session) reads via `git log` to understand the story behind the guide.
   - `git -C <brain> add <files> && git -C <brain> commit -F <msg> && git -C <brain> push`.
   - A future session can recall via `git log --follow -p docs/<guide>.md`, `git show <sha>`, `git blame`, or `git log --stat` — treat git history as a first-class recall tool.

## Invariants

- **Never auto-write.** Approval precedes every write *and* every commit/push.
- **INDEX stays in sync.** Adding/removing/re-scoping a guide always reconciles `INDEX.md`. (User's explicit rule.)
- **Prefer growing a guide over forking one.** Near-duplicate guides fragment knowledge; merge into the closest existing guide. Only split when a guide accretes a genuinely *unrelated* second topic (then update INDEX).
- **Every accepted learning is committed with a why-rich message and pushed.** The diff is the *what*; the commit body is the *why*.
