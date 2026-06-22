---
description: Review this session for durable learnings and propose them into YOUR personal brain (approve/edit/reject before any write).
---

You are running the **knowledge-capture** procedure. It saves learnings into the user's **personal**
brain (their own private repo) — NOT the shared team repo (that's `/capture-to-team`). Full spec:
`procedure/capture.md` in the team brain.

**Find the personal brain first.** Ask the user where their personal brain lives if you don't already
know (it was set up during onboarding, often a sibling like `<base>/my-brain`). Everything below
operates on THAT repo. If they don't have one yet, offer to run `/bootstrap-project` to create it.

## Steps

1. **Scan this session** for durable learnings. Capture ONLY:
   - gotchas that took multiple retries (deploy errors, metadata quirks, API/CLI/env surprises),
   - non-obvious prompts/workflows that worked,
   - tooling/environment quirks.
   Skip one-off task details, project-specific paths, generic best practices, and anything git/the repo already records. If nothing qualifies, say so and stop.

2. **Read the personal brain's `INDEX.md`** to see existing guides and their descriptions.

3. **Classify each candidate:**
   - *Personal fact* (org table, profile, per-project status) → recommend it go to the workspace `CLAUDE.md` or native memory, NOT a guide.
   - *Shareable gotcha* → **prefer appending/merging into the closest existing guide** (guides are living and meant to grow). Propose a **new** guide from `docs/_TEMPLATE.md` only when no existing guide is a near fit.

4. **Propose, do not write.** For each candidate show:
   - target file,
   - exact text to add or change,
   - whether the one-line `INDEX.md` trigger needs adding/updating,
   - the **commit message** (subject + why-body) you'd use.
   Let the user **approve / edit / reject** each item individually.

5. **On approval only**, for each approved item:
   - edit the guide (append/merge if related; in place if superseding; never append a contradiction),
   - bump that guide's `last_verified:` to today, and set `last_verified_with:` (and `authored_with:` for a new guide) to the current model ID,
   - keep the front-matter `description:` an accurate **1–5 line summary of the whole guide** (one line unless its breadth needs more); widen it if scope grew,
   - reconcile the guide's **one-line `INDEX.md` trigger** so it stays consistent with (not identical to) the front-matter summary; re-scan INDEX ↔ `docs/` for drift,
   - print the diff of everything written.

6. **Commit + push (the history layer).** After the user accepts the written changes:
   - stage only the touched files (one commit per coherent learning when practical),
   - commit with subject `capture(<guide>): <what was learned>` (≤72 chars) and a body explaining **why** — what we were doing, what failed / how many retries, root cause, what worked, confidence,
   - `git -C <personal-brain> add <files>` → `commit` → `push`.
   The why-rich history is itself recall fuel: future sessions can run `git log --follow -p docs/<guide>.md`, `git show <sha>`, or `git blame docs/<guide>.md`.

## Hard rules

- **Never auto-write.** Approval precedes every write **and** every commit/push.
- **INDEX must stay in sync** with `docs/` — but the INDEX line is a one-liner, NOT a verbatim copy of the (possibly longer) front-matter `description`.
- **Prefer growing an existing guide** over creating a near-duplicate.
- **Every accepted learning is committed with a why-rich message and pushed.**
- This saves to YOUR personal brain. To share a guide with the team, use **`/capture-to-team`** afterward.
- Do **not** modify per-project status files or native memory as part of this command unless the user asks.
