# INDEX — Q Branch LATAM brain catalog

**Lazy-scan layer.** Read this file first. Each line is a guide + a **one-line** "open me when…" trigger. Open a `docs/<name>.md` body **only when its line matches the task at hand** — do not load guides speculatively. This keeps per-session token cost flat as the knowledge base grows.

The line here is the *short form*. Each guide's own front-matter `description` is the *long form* — a 1–5 line summary of the full file. The two must stay **consistent** (the one-liner is a faithful subset of the summary) but need **not** be identical. To add/change a guide, use **`/capture-to-team`** — it reconciles this index.

## Guides

- `docs/agentforce-metadata-and-deploy.md` — Agentforce metadata conventions (GenAiPlannerBundle vs old, deploy manifests) + runtime/deploy gotchas (SYSTEM_MODE DML, ID validation, publish blockers, Instructions truncation).
- `docs/agentforce-builder-navigation.md` — Atlas orgs have TWO Agentforce builders. Always use the new Builder direct URL; the actual New Agent wizard shape (Skip Ahead); editing published agents; loading the developing-agentforce skill.
- `docs/atlas-org-preflight.md` — Verify an org actually runs Agent Script/Atlas BEFORE building (empty bundle list ≠ unsupported; only INVALID_TYPE means absent). Where to get Atlas trial orgs; enabling toggles on fresh OrgFarm orgs.
- `docs/salesforce-browser-automation.md` — Playwright/Chrome gotchas on Salesforce — Flows in iframes, Lightning app deep-link context, Setup vs Lightning host swap, frontdoor verification interstitial, Setup→All Sites auth-bound link, login completion checks.
- `docs/experience-cloud-lwr.md` — LWR htmlEditor strips <style>/class CSS (inline styles only); sf project deploy won't replace media-backed CSS files; must sf community publish after deploy to go live.
- `docs/headless-visual-verification.md` — How to screenshot/automate Chrome on an MDM-locked Mac — Cloud Management blocks CDP on system Chrome; use Chrome for Testing or a throwaway --user-data-dir; the visual-verify.sh reference script; Playwright MCP browser_close caveat.
- `docs/react-multiframework.md` — Building React apps deployed to Salesforce via Multi-Framework (UIBundle) — org gating, Apex REST proxy for guest/Experience data, embedding agents (ACC vs MIAW), the 3-pass skill workflow, CLI gotchas, build hygiene.
- `docs/sfdx-metadata-gotchas.md` — ContentAsset folder-per-asset layout for packaging; OmniStudio/OmniScript deploy gotchas; FSC managed→platform Flow translation; Action Launcher + FlexiPage wiring.
- `docs/salesforce-core-gotchas.md` — Cross-cutting Salesforce deploy/runtime gotchas — LWC @wire reactivity & proxy spread, Experience Cloud hex-not-rgb, SDO profile naming, NAME field in layouts, tab-before-permset ordering, Slack-as-channel constraints.
- `docs/org-and-tooling-reference.md` — Fresh OrgFarm login flow (MFA code via Slack + skip-phone interstitial, persistent profile); devbar auth for statusline cost; sf CLI sandbox/log gotchas (HttpsProxyAgent, EPERM logs).
- `docs/build-log-pattern.md` — Open when setting up a project's working-memory log: the append-only build-log.md the AI maintains autonomously (Context-Stack Layer 2), the drop-in trigger-rule block, what to log vs skip, and how it differs from /capture and git.
- `docs/heroku-deploy.md` — Deploying to Heroku from the CLI: app name gets a random hash suffix (real URL ≠ <name>.herokuapp.com); `git subtree push --prefix <dir> heroku main` to deploy a subfolder (Procfile/package.json at the subtree root); tiny Express server.js beats the unmaintained static buildpack; `heroku login` needs an interactive shell.

## Procedure & config (not lazy-scan guides — read when relevant)

- `README.md` — what this repo is, how to read it, how to contribute (start here).
- `CONTRIBUTING.md` — how to promote a guide (the `/capture-to-team` flow + Opus quality gate).
- `config/setup-prompt.md` — paste-and-go onboarding prompt for a new teammate.
- `procedure/capture.md` — what `/capture` does (saves to your personal brain).
- `procedure/capture-to-team.md` — what `/capture-to-team` does (promotes a guide here).
