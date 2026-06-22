# Q Branch LATAM — Brain Setup Prompt

> **How to use this:** copy everything in the code block below and paste it as your first message
> in a fresh Claude Code session. Claude will set up your personal "brain" + wire it to the team
> brain. It asks before touching anything and never assumes where your files live.

```text
You are setting me up with the Q Branch LATAM "Context Stack" — a knowledge system so you stop
forgetting hard-won lessons between sessions. Do this carefully, ask me before destructive steps,
and NEVER hardcode another person's folder paths. Work through these phases:

PHASE 0 — Orient
- Confirm `gh auth status` shows me logged in to github.com. If not, tell me to run `gh auth login`.
- Ask me ONE question: "Where do you want your brains to live?" Offer a sensible default
  (e.g. `~/claude-brains/`). Under that base I'll have two things: the TEAM brain (a clone) and
  MY OWN personal brain (new). Do not proceed until I confirm the base directory.

PHASE 1 — Clone the team brain (shared, read-mostly)
- Clone the public team repo into <base>/q-branch-latam-brain:
  `gh repo clone q-branch-latam/claude-brain <base>/q-branch-latam-brain`
- Read its README.md and INDEX.md so you understand what's there. Summarize the available guides
  for me in 2-3 lines. This is the shared knowledge — I read it, and I copy guides I want into my
  personal brain. I do NOT edit it directly except via the /capture-to-team command.

PHASE 2 — Wire the slash commands + hook (from the team clone)
- Symlink the commands into ~/.claude/commands/ (create the dir if missing). Point them at the
  team clone's config/commands/ so they update when I `git pull`:
    ln -sf "<base>/q-branch-latam-brain/config/commands/capture.md"          ~/.claude/commands/capture.md
    ln -sf "<base>/q-branch-latam-brain/config/commands/capture-to-team.md"  ~/.claude/commands/capture-to-team.md
    ln -sf "<base>/q-branch-latam-brain/config/commands/bootstrap-project.md" ~/.claude/commands/bootstrap-project.md
- Install the session-end reminder hook. Copy
  `<base>/q-branch-latam-brain/config/hooks/session-end-capture.sh` to
  `~/.claude/hooks/claude-brain/session-end-capture.sh`, `chmod +x` it, then MERGE it into the
  "Stop" hooks array in ~/.claude/settings.json. CRITICAL: merge — read the existing JSON, append
  this one hook entry, write it back. Do NOT overwrite existing hooks. If ~/.claude/settings.json
  doesn't exist, create it with a minimal valid structure. Show me the before/after of the Stop array.

PHASE 3 — Install Layer-0 awareness (global)
- Ensure ~/.claude/CLAUDE.md exists. If it doesn't, create it from
  `<base>/q-branch-latam-brain/config/global-CLAUDE.md.tmpl`, replacing <BRAIN_PATH> with
  `<base>/q-branch-latam-brain`. If it DOES exist, show me the template and ask whether to append
  the awareness block — never clobber my existing global file.

PHASE 4 — Create MY personal brain (private, mine)
- Tell me: the team brain is shared; my personal brain is where I gather MY learnings before
  (optionally) promoting the best ones to the team. Offer to scaffold it now at
  <base>/my-brain by running the /bootstrap-project flow there, and to create it as a PRIVATE
  GitHub repo under my account. Ask before creating any remote repo.

PHASE 5 — Teach me the loop
- Print a short cheat-sheet:
  • /capture          → save a learning to MY personal brain (approve before write).
  • /capture-to-team  → promote one of my guides to the TEAM brain (Opus reviews it first).
  • To USE team knowledge: read <base>/q-branch-latam-brain/INDEX.md, open the matching guide,
    copy what's relevant into my own brain.
  • /bootstrap-project → set up the Context Stack (git + build-log + CLAUDE.md) in any new project.
- Confirm everything: list the symlinks created, the hook merge result, and both brain locations.

Throughout: ask before creating remote repos or editing my global config. Report what you did.
```

## What this sets up (for humans reading before they run it)

- **Team brain clone** — the shared `q-branch-latam/claude-brain`, read for knowledge, contributed to via `/capture-to-team`.
- **Your personal brain** — your own private repo; `/capture` feeds it; it's yours to curate.
- **Three slash commands** — `/capture`, `/capture-to-team`, `/bootstrap-project`.
- **A session-end nudge** — reminds you to `/capture` when a session produced something durable.
- **Layer-0 awareness** — a tiny global `~/.claude/CLAUDE.md` so every future session knows the procedure exists (gated to real project work; ignored for throwaway chats).

It is **additive and safe**: it asks before creating remote repos and merges (never overwrites) your existing Claude config.
