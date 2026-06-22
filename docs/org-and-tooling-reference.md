---
name: Org Login & Tooling Reference
description: Fresh OrgFarm login flow (MFA code via Slack + skip-phone interstitial, persistent profile); devbar auth for statusline cost; sf CLI sandbox/log gotchas (HttpsProxyAgent, EPERM logs).
last_verified: 2026-06-19
tags: [orgfarm, mfa, devbar, sf-cli, login, tooling]
authored_with: claude-sonnet-4-6
last_verified_with: claude-sonnet-4-6
---

# Org Login & Tooling Reference

Open this for: logging into a fresh OrgFarm trial org, devbar/statusline auth, or `sf` CLI sandbox/log errors.

## Fresh OrgFarm trial login — TWO sequential interstitials
First login to a fresh `epic.*@orgfarm.salesforce.com` org with a new browser profile hits two screens before Lightning:

1. **Device/email verification (MFA).** The code is **NOT emailed** — it lands in Slack channel **`#orgfarm-orgs-mfa-codes`** ~15s after the prompt. Read it (Slack MCP `slack_read_channel`), match the most recent message for the org's username, enter it.
2. **"Add phone number" identity screen.** Click **"Skip" / "Skip and don't ask again"** — safe to dismiss permanently.

**Automation (Playwright):**
- Use `chromium.launchPersistentContext('/tmp/cft-<purpose>-profile', ...)` — both interstitials only fire **once per profile**; re-runs skip both.
- The auth wait loop must check for BOTH `lightning.force.com` AND the identity/phone URL (contains `identity`/`phone`). A loop that only checks `!url.includes('login.salesforce.com')` falsely exits on the phone interstitial → next `goto()` bounces back to login.
- All OrgFarm workshop orgs share password `orgfarm1234`.

## devbar authentication (statusline cost field)
The 💵 cost field in the statusline needs devbar signed in via Salesforce SSO:
```bash
devbar auth login            # opens browser Okta/SSO (signs in as gdedios@salesforce.com)
devbar auth login --device   # headless/SSH
devbar auth status           # check
```
Without it, `devbar status litellm --json` returns "authentication required" and the statusline silently hides the cost field.

## sf CLI sandbox / log gotchas
- **Command sandbox breaks `sf` networking.** In sandboxed Claude Code sessions, `sf` proxies/mocks the network → `HttpsProxyAgent`/`this._getSession` errors and false "not authenticated". Run `sf` with the sandbox disabled, or in a regular terminal. Auth files in `~/.sfdx/` are read identically by `sf` and `sfdx`.
- **`~/.sf/*.log` EPERM:** prefix `export SF_DISABLE_LOG_FILE=true` to dodge log-file write-permission errors in this shell setup.
- **Session caching:** keep "Enable secure and persistent browser caching" OFF (Setup → Session Settings) on demo orgs — it causes sticky app-context bugs where freshly deployed FlexiPages don't render under their assigned app.

## Related

- Verifying Atlas capability + enabling Einstein/Agentforce toggles → `docs/atlas-org-preflight.md`
- Headless Chrome / frontdoor URLs → `docs/headless-visual-verification.md`
