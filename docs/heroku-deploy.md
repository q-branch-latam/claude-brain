---
name: Heroku Deploy
description: >-
  Deploying a site to Heroku from a CLI session: the app name gets a random
  hash suffix (real URL ≠ <name>.herokuapp.com — read it from create output);
  deploy a subfolder with `git subtree push --prefix <dir> heroku main` (the
  Procfile/package.json must sit at the SUBTREE root, not the repo root); a
  static page is most robust as a tiny Express server.js (the community static
  buildpack is unmaintained); and `heroku login` can't run inside an agent tool
  shell (setRawMode error) — the user must run it interactively.
last_verified: 2026-06-23
authored_with: claude-opus-4-8
last_verified_with: claude-opus-4-8
tags: [heroku, deploy, cli, static-site, node, express]
---

# Heroku Deploy

## When this applies / Symptom

Deploying a web page/app to Heroku via the CLI — especially the first time, when
the site lives in a **subfolder** of a larger repo (e.g. a `site/` dir inside a
knowledge-base repo), and you're driving it from an automated/agent session.

## The fix / How it works

**1. `heroku login` is interactive — the user must run it.** Inside an agent tool
shell it dies with `TypeError: process.stdin.setRawMode is not a function` (no TTY
for the "press any key" browser-auth flow). Have the user run `heroku login` (or
`! heroku login`) themselves; everything after auth (`create`, `subtree push`,
`ps`, `open`) runs fine non-interactively.

**2. The app name gets a random hash suffix.** `heroku create q-branch-latam-brain`
does NOT give you `q-branch-latam-brain.herokuapp.com`. The create output prints the
real URL, e.g. `https://q-branch-latam-brain-9942e218be1b.herokuapp.com/`. Always
read the URL from the command output — don't assume `<name>.herokuapp.com`.

**3. Deploy a subfolder with `git subtree push`.** Heroku expects `Procfile` +
`package.json` at the root of what it receives. If the app lives in `site/`:

    git subtree push --prefix site heroku main

Heroku then sees `site/`'s contents AS the root and detects Node correctly. The
build artifacts (`Procfile`, `package.json`, `server.js`) must sit at the **subtree
root** (inside `site/`), not the repo root. Redeploy after edits = re-run the same
subtree push.

**4. Serve a static page with a tiny Express server, not the static buildpack.** The
community static buildpack is unmaintained. A ~12-line `server.js` using
`express.static(__dirname)` + a `Procfile` of `web: node server.js` + a `package.json`
with `"start": "node server.js"` and an `express` dep is far more robust and Just Works.

**5. Dyno tier = sleep behaviour.** A `Basic` (paid) dyno is always-on. The free/Eco
tier sleeps after ~30 min idle (first hit after sleep wakes in ~5–10s). Check with
`heroku ps -a <app>` — the type shows e.g. `web (Basic)`.

## Why (the part the code/diff can't show)

First-ever Heroku deploy (the q-branch-latam team-brain story page). Four surprises,
each cost a step:
- `heroku login` inside the agent shell threw `setRawMode` — had to hand it back to
  the user's interactive `!` prompt. (High confidence; it's a TTY requirement, not a
  fluke.)
- Assumed the URL would be `<name>.herokuapp.com` and would have linked a dead URL —
  the hash suffix is mandatory and only shown in `create` output.
- The page lived in `site/`, so a plain `git push heroku main` would have pushed the
  repo root (no Procfile there → no Node detection). `git subtree push --prefix site`
  is the clean fix — no separate deploy repo needed.
- Chose Express over the static buildpack on the buildpack's unmaintained status;
  build succeeded first try (Node detected, `web` dyno up).

All verified live: HTTP 200, assets load, headless render over https confirmed.

## References

- Live example: the `site/` folder + `server.js`/`Procfile`/`package.json` in the
  team brain repo (`q-branch-latam/claude-brain`).
- Related: `docs/headless-visual-verification.md` (how the deployed page was render-verified).
