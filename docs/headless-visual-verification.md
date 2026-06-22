---
name: Headless Visual Verification (MDM-locked Mac)
description: How to screenshot/automate Chrome on this MDM Mac — Cloud Management blocks CDP on system Chrome; use Chrome for Testing or a throwaway --user-data-dir; the visual-verify.sh reference script; Playwright MCP browser_close caveat.
last_verified: 2026-06-19
tags: [chrome, mdm, headless, playwright, screenshots, cdp]
authored_with: claude-sonnet-4-6
last_verified_with: claude-sonnet-4-6
---

# Headless Visual Verification (MDM-locked Mac)

Open this for: taking automated screenshots of deployed Salesforce changes, or "DevTools remote debugging is disallowed by the system admin" errors.

## The constraint
System Chrome on this Mac is enrolled in **Chrome Cloud Management** (`/Library/Managed Preferences/com.google.Chrome.plist` has `CloudManagementEnrollmentToken`). A cloud policy sets `RemoteDebuggingAllowedOrigins=[]`, blocking CDP with:
```
DevTools remote debugging is disallowed by the system admin.
```
The policy re-fetches every Chrome boot, so restarting doesn't help. There are two working paths depending on the tool.

## Path A — headless screenshots via throwaway user-data-dir (simplest, no MCP)
For one-shot screenshots, a fresh `--user-data-dir=/tmp/chrome-claude-profile` escapes the managed default profile and allows `--headless=new --screenshot`. **Reusable reference script** (proven 2026-05-05 on ASSIST-110258, copy it into new projects — don't re-solve from scratch):
```
Projects/05-2026/assist-110258-comfandi/scripts/visual-verify.sh
```
Usage:
```bash
bash scripts/visual-verify.sh "/lightning/r/Account/<ID>/view" /tmp/out.png --org <alias>
```
It (1) mints an authenticated `frontdoor.jsp?otp=...` via `sf org open --url-only`, (2) uses a fresh `/tmp/chrome-claude-profile` (deleted each run), (3) runs `--headless=new --disable-gpu --virtual-time-budget=15000 --screenshot`, (4) verifies the PNG isn't a blank/error page.
- Lightning SPA needs `--virtual-time-budget=15000` minimum; **bump to 30000** for CRM Analytics / Wave dashboards or it screenshots before bootstrap.
- The frontdoor OTP is single-use and short-lived (~60s); the script mints a fresh one each run.
- One snapshot at 1440×900 (configurable via `SIZE`). No click/scroll interaction.
- Research + failed paths: `assist-110258-comfandi/docs/visual_verification_research_results.md`.

> Note: for the **interactive Playwright MCP** the throwaway data-dir does NOT bypass the policy (it blocks `--remote-debugging-pipe` too) — use Path B for that.

## Path B — Playwright MCP: point at Chrome for Testing
**Chrome for Testing** (downloaded by `npx playwright install chromium`) is NOT enrolled in Cloud Management, so CDP works on it.
1. `npx --yes playwright install chromium`
2. Edit `~/.claude/plugins/marketplaces/claude-plugins-official/external_plugins/playwright/.mcp.json`:
   ```json
   { "playwright": { "command": "npx", "args": ["@playwright/mcp@latest", "--executable-path",
     "/Users/gdedios/Library/Caches/ms-playwright/chromium-<ver>/chrome-mac-arm64/Google Chrome for Testing.app/Contents/MacOS/Google Chrome for Testing"] } }
   ```
3. **Restart the Claude Code CLI session** (MCP config is read on start).
- Verify unmanaged: launch with `--remote-debugging-port=9444 --user-data-dir=/tmp/cft-test`, then `curl http://127.0.0.1:9444/json/version` → JSON with `"Browser":"Chrome/..."` and no "disallowed by the system admin".
- **Version drift:** the path includes `chromium-<ver>` (e.g. 1217). After `playwright install` upgrades it, the path goes stale — re-pin.
- Alternative without editing config: launch CFT with `--remote-debugging-port=9222` and attach via `--cdp-endpoint http://127.0.0.1:9222`.

## Playwright MCP: never `browser_close` mid-session
On this MDM Mac, after `browser_close` Playwright cannot re-launch Chrome with CDP (180s `initializeServer` timeout, "DevTools remote debugging is disallowed"). Only re-launch is blocked; the first launch is fine. **Keep one Chrome instance alive** from first navigation to last screenshot. To get a clean auth session, generate a new `frontdoor` URL and `browser_navigate` to it (don't close). If Chrome gets stuck, ask the user to restart the computer rather than retrying `browser_close`.

## Related

- Salesforce-specific Playwright navigation gotchas → `docs/salesforce-browser-automation.md`
