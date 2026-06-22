# Q Branch LATAM — the shared brain 🧠

A shared, version-controlled knowledge base so **Claude stops forgetting our hard-won lessons**
between sessions — and so the whole team benefits from each other's learnings.

This is **Layer 3** of a four-layer "Context Stack" (Bera Aksoy's three-layer model + an awareness
layer). The idea: durable, teachable gotchas live in topic-named `docs/*.md` guides, catalogued in a
thin `INDEX.md`. Claude reads the index first and opens a guide **only when it's relevant** — so the
always-loaded context cost stays flat no matter how much the team learns.

## The federated model

```
Each teammate:  /capture → their OWN private brain      (gather fast, solo)
Best learnings: /capture-to-team → THIS public repo     (curated, Opus-reviewed)
Everyone:       read INDEX.md → copy the guides you want into your own brain
```

- **Your personal brain** is private and yours. `/capture` saves learnings there after every session.
- **This team brain** is public and shared. You promote a guide here with `/capture-to-team`, which
  runs an Opus review (clarity / self-containment / accuracy) before it's committed.
- **Pulling is manual and intentional:** read this repo's `INDEX.md`, open a matching guide, copy
  what's useful into your own brain. No auto-sync, no forced merges, no clobbering your notes.

## I'm new — how do I set this up?

Open **`config/setup-prompt.md`**, copy the prompt block, and paste it into a fresh Claude Code
session. It clones this repo, wires the slash commands + a session-end reminder, installs the global
awareness file, and offers to scaffold your own personal brain. It asks before touching anything and
never assumes where your files live.

## I just want to read a guide

Open **`INDEX.md`**, scan the one-liners, open the guide whose trigger matches your task. That's it.

## How do I contribute a guide?

See **`CONTRIBUTING.md`**. Short version: from a session where you learned something durable, run
`/capture` (saves to your brain), then `/capture-to-team` (Opus reviews it, then it lands here).

## What's in here

| Path | What |
|---|---|
| `INDEX.md` | The catalog — read first. |
| `docs/*.md` | The guides — load on demand. |
| `config/setup-prompt.md` | Paste-and-go onboarding for a new teammate. |
| `config/commands/*.md` | The `/capture`, `/capture-to-team`, `/bootstrap-project` slash commands. |
| `config/templates/*.tmpl` | Project scaffolding templates (build-log, project CLAUDE.md, .gitignore). |
| `config/global-CLAUDE.md.tmpl` | The Layer-0 awareness file installed into `~/.claude/CLAUDE.md`. |
| `procedure/*.md` | The "why" behind each command. |

## Notes

- This repo is **public** by deliberate team choice. We're demo engineers — no client data, no
  secrets/keys live here. Internal demo-org usernames and internal channel names may appear; that's
  acceptable for our purposes. **Never** commit live access tokens, `frontdoor.jsp?otp=` URLs, or
  session IDs.
- Guides carry `last_verified` + `authored_with` / `last_verified_with` (which model). Stale-but-confident
  is worse than absent — if a guide looks out of date, flag it or re-verify and bump the date.

Credit: the Context Stack model originates with **Bera Aksoy** (AFD360 L3 build week).
