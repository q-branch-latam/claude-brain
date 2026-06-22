---
description: Scaffold the full Context Stack in the current project folder — docs/, build-log.md, git init (+ optional private GitHub repo), and a project CLAUDE.md from the brain template.
---

You are bootstrapping the **Context Stack** for a project so it teaches its own context to the AI
across all four layers. The team brain (with `config/templates/`) is the cloned `q-branch-latam-brain`
repo — ask the user for its path if you don't know it.

## Before doing anything

1. **Confirm the target folder.** Use the current working directory unless the user names another. State the absolute path and ask for confirmation if ambiguous.
2. **Detect what already exists** — `CLAUDE.md`, `build-log.md`, `docs/`, `.git`, `.gitignore`. **Never overwrite** an existing file; if one exists, propose a merge/append and ask. This command is additive.
3. Ask the user for: the **project name**, a one-line **what-this-is**, and the **org alias** (if Salesforce). If they don't answer, leave the template placeholders and note them.

## Scaffold (Layers 1–3; Layer 0 is the global ~/.claude/CLAUDE.md, set during onboarding)

1. **`docs/`** — create if absent (the project's own durable notes; distinct from the shared brain).
2. **`build-log.md`** (Layer 2) — create from the brain's `config/templates/build-log.md.tmpl`, substituting `<PROJECT_NAME>` and `<DATE>` (ask the user for today's date — do not invent one). Seed the first `[milestone]` + `[next]` bullets.
3. **`CLAUDE.md`** (project guardrails + Layer-2 trigger block + brain pointer) — create from `config/templates/project-CLAUDE.md.tmpl`:
   - `<PROJECT_NAME>`, `<ONE_OR_TWO_LINES>`, `<PROJECT_SPECIFIC>` from the user's answers.
   - `<BRAIN_RELATIVE_PATH>` = the correct relative path from THIS project to the team brain clone (compute it).
4. **`.gitignore`** — if absent, copy `config/templates/salesforce.gitignore.tmpl`. If the project has no `node_modules`/`dist`, that's fine — the rules are harmless. **Review it against the actual folder contents** and tell the user what will be ignored (especially screenshots — the template ignores them by default; un-ignore if they're load-bearing docs).

## Layer 1 — git

5. **`git init`** if there's no `.git`. Then a **secrets/size audit BEFORE the first commit**:
   - `git add -A` then `git status --short` — review the staged list.
   - Scan staged files for secrets: tokens, `frontdoor.jsp?otp=`, `access_token`, `-----BEGIN`, bearer tokens, `.env`. If any are staged, STOP, fix `.gitignore`, and re-stage.
   - Flag any file > ~5 MB or binary blobs; confirm they belong in git or add to `.gitignore`.
6. **First commit** with a why-rich message (subject: `chore: bootstrap Context Stack for <project>`).

## Optional — private GitHub repo (ask first)

7. Ask whether to also create a **private GitHub repo + push**. If yes:
   - Confirm `gh auth status` shows github.com active as the intended account.
   - `gh repo create <your-username>/<repo-name> --private --source . --remote origin --push`.
   - **Re-run the secrets audit on the committed tree** (`git ls-files | xargs grep ...`) and confirm the repo is `PRIVATE` (`gh repo view --json visibility`) BEFORE considering it done.
   - This is an outward-facing publish — get explicit confirmation before pushing.

## After

8. Print a summary: files created, what `.gitignore` excludes, git/remote status, and the brain-pointer path.
9. Remind: the build-log is now maintained **autonomously** per the trigger rules; durable gotchas still go through **`/capture`** to reach your personal brain, and the best of those reach the team via **`/capture-to-team`**.

## Hard rules

- **Additive, never destructive.** No overwrites without explicit approval.
- **Audit before every commit and before any push.** Secrets and large binaries never reach git/GitHub.
- **Don't invent dates.** Ask the user for the current date for the build-log seed.
- Personal facts (org creds, profile) stay project-local / in native memory — not in the shared brain.
