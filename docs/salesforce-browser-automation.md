---
name: Salesforce Browser Automation (Playwright)
description: Playwright/Chrome gotchas on Salesforce — Flows in iframes, Lightning app deep-link context, Setup vs Lightning host swap, frontdoor verification interstitial, Setup→All Sites auth-bound link, login completion checks.
last_verified: 2026-06-19
tags: [playwright, browser, salesforce, lightning, experience-cloud]
authored_with: claude-sonnet-4-6
last_verified_with: claude-sonnet-4-6
---

# Salesforce Browser Automation (Playwright)

Open this for: scripting Playwright against Salesforce Lightning / Setup / Experience Cloud, or "button never found" / "bounced back to login" symptoms.

## Lightning Flows render inside an iframe
Flows live on a `*--c.develop.vf.force.com` (Visualforce) origin, not the main `lightning.force.com` page. `page.locator('button:has-text("…")')` on the main page never finds the button. **Iterate `page.frames()`**, find the matching frame, then use the frame's locator.

## Lightning app deep links don't switch app context
Navigating to `/lightning/app/<DeveloperName>` keeps whichever app the user was last in (and its Home flexipage), so a per-app `actionOverride` for `standard-home` never fires. Workarounds: (1) click the App Launcher tile programmatically, then click the `Home` tab inside the app to force the per-app flexipage; (2) `/lightning/n/<DevName>` is for **Custom Tab** dev names only — direct flexipage URLs return "Page doesn't exist."

## Setup pages live on a DIFFERENT host
After a Setup URL, `page.url()` is `*.develop.my.salesforce-setup.com`. A `/lightning/app/...` request there routes back through login. **Swap the host** (`.my.salesforce-setup.com` → `.lightning.force.com`) before any non-Setup navigation.

## Login looks done but isn't (verification interstitial)
Frontdoor login redirects through `/_ui/identity/verification/method/...`. A check like `!url.startsWith('https://login.salesforce.com')` passes while still on the interstitial, and the next `goto` bounces back to login. **Wait until the URL contains `lightning.force.com` or `/lightning/`** before treating login as complete. (See `docs/org-and-tooling-reference.md` for the fresh-OrgFarm two-interstitial flow.)

## Setup → All Sites: the URL link is auth-bound
To open an Experience Cloud site as admin (no community user):
1. Setup → All Sites (`/lightning/setup/SetupNetworks/home`).
2. Click the **URL link in the right-most column** (dark text, `target="_blank"`) — it opens a new tab pre-authenticated as admin.

Its href is `/servlet/networks/switch?networkId=<NetworkId>` — a session-bound network-switch endpoint. **Copying the visible public URL into a fresh tab won't work** (it hits login); the switch redirect mints the `*.my.site.com` cookies. Pattern:
```js
for (const f of page.frames()) {
  const link = f.locator('a[href*="/servlet/networks/switch"]')
    .filter({ hasText: '/<urlPathPrefix>' }).first();
  if (await link.count()) {
    const newTabPromise = context.waitForEvent('page', { timeout: 30000 });
    await link.click({ force: true });
    const newTab = await newTabPromise;
    // wait until newTab.url() includes my.site.com/<urlPathPrefix>, then ~8s for LWR SPA boot
  }
}
```
Prefer this over guest access — idle OrgFarm orgs get guest-profile config drift, so the public URL redirects to login even when guest access tested fine earlier.

## Flexipage Home buttons that launch Flows
Use `flexipage:richText` + `<a href="/flow/...">`, never `flexipage:flow` (that's screen flows on records, not Home).

## Related

- CDP/MDM block + headless screenshots → `docs/headless-visual-verification.md`
- Builder-specific automation (wizard shadow roots, popups) → `docs/agentforce-builder-navigation.md`
- Fresh-org login interstitials & MFA → `docs/org-and-tooling-reference.md`
