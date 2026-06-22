---
description: Promote one or more guides from your personal brain to the public q-branch-latam/claude-brain team repo, gated by an Opus clarity review (approve/edit/reject before any push).
---

You are running the **promote-to-team** procedure: lifting a durable guide from the user's
**personal** brain into the **public team** brain at `q-branch-latam/claude-brain` so the whole
Q Branch LATAM team can read it. Full spec: `procedure/capture-to-team.md` in the team brain.

The personal brain (source) is wherever the user set it up — ask if unknown.

## Steps

1. **Locate the team-repo clone (target).** In order:
   - look for an existing clone (try `git -C <candidate> remote get-url origin` against a couple of likely sibling dirs, e.g. `../q-branch-latam-brain`, `~/q-branch-latam-brain`);
   - if none is found, clone it fresh: `gh repo clone q-branch-latam/claude-brain <sibling>/q-branch-latam-brain` then `git -C <clone> pull`.
   Call the resolved path `TEAM`. Always `git -C "$TEAM" pull` before doing anything so you're current.

2. **Pick the guide(s) to promote.** If the user named a guide, use it. Otherwise, propose candidates: diff the personal `docs/*.md` against `TEAM/docs/` and list guides that are **new** or **changed** (these are the promote-worthy ones). Let the user choose.

3. **Run the Opus clarity gate (one per guide).** Spawn a subagent with `model: opus` whose job is a **clarity / self-containment / accuracy** review — explicitly **NOT** a security or sanitization pass (the team repo is public by deliberate choice; internal SF identifiers are allowed). Give it the full guide text and this rubric:
   > "You are reviewing a knowledge-base guide before it's shared with teammates who were NOT in the session that produced it. Judge ONLY: (a) **Self-contained** — can a teammate act on this without the author's missing context? (b) **Clear** — is it well-organized and unambiguous? (c) **Accurate / not stale** — do the steps look correct and current? (d) **Durable** — is this teachable knowledge vs. one-off session trivia? Do NOT flag internal Slack channels, colleague names, org usernames, or the orgfarm password — the repo is intentionally public and those are allowed. Return exactly one verdict: `APPROVED` / `NEEDS_EDIT` / `KEEP_PERSONAL`, then a one-paragraph rationale, then (if NEEDS_EDIT) a short bulleted list of concrete fixes."

4. **Show the user the verdict + rationale** for each guide. They **approve / edit / reject**:
   - `APPROVED` → proceed to write.
   - `NEEDS_EDIT` → apply the suggested fixes (to the **personal** guide first so both copies improve, or just the team copy if the user prefers), then proceed.
   - `KEEP_PERSONAL` → skip; do not promote.

5. **On approval, write into `TEAM`:**
   - copy the guide to `TEAM/docs/<name>.md` (overwrite if updating an existing one),
   - set its front-matter `last_verified:` to today and `last_verified_with: claude-opus-4-8` (Opus ran the gate); keep `authored_with` as-is,
   - **reconcile `TEAM/INDEX.md`** — add or update the guide's one-line trigger; re-scan INDEX ↔ `TEAM/docs/` for drift,
   - print the diff of everything written into `TEAM`.

6. **Commit + push — auto-detect access:**
   - check the runner's permission: `gh repo view q-branch-latam/claude-brain --json viewerPermission -q .viewerPermission`.
   - **ADMIN / MAINTAIN / WRITE** (Gonzalo / maintainers) → commit directly to `main` and push:
     - `git -C "$TEAM" add docs/<name>.md INDEX.md`
     - commit subject `promote(<guide>): <one-line summary>` (≤72 chars); body must quote the Opus verdict + rationale, e.g. `Opus review: APPROVED — <rationale>`.
     - `git -C "$TEAM" push`.
   - **READ / none** (a teammate without write) → branch + PR:
     - `git -C "$TEAM" checkout -b promote/<guide>`, commit (same message format), `git -C "$TEAM" push -u origin promote/<guide>`,
     - `gh pr create -R q-branch-latam/claude-brain --title "promote(<guide>): <summary>" --body "<Opus verdict + rationale>"`,
     - return on `main` afterward.

7. **Report** the resulting commit URL or PR URL.

## Hard rules

- **Never auto-promote.** The Opus verdict is advisory; the **user** approves every push/PR.
- **The gate is clarity, not security.** Do NOT strip internal identifiers — the repo is public by deliberate, recorded choice.
- **INDEX stays in sync** in the team repo too — one-liner trigger, consistent with (not identical to) the front-matter description.
- **Always `git pull` the team clone first** to avoid stale-base conflicts.
- This command promotes **personal → team**. It does not edit the personal brain except optionally to apply a `NEEDS_EDIT` fix (which the user approves) so the source guide also improves.
