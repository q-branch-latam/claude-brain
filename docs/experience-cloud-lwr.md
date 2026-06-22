---
name: Experience Cloud LWR Site Gotchas
description: LWR htmlEditor strips <style>/class CSS (inline styles only); sf project deploy won't replace media-backed CSS files; must sf community publish after deploy to go live.
last_verified: 2026-06-19
tags: [experience-cloud, lwr, css, deploy, digital-experience]
authored_with: claude-sonnet-4-6
last_verified_with: claude-sonnet-4-6
---

# Experience Cloud LWR Site Gotchas

Open this for: branding/editing an LWR Experience Cloud site via SFDX, or "my CSS/styles didn't show up after deploy."

## htmlEditor sanitizer — inline styles ONLY
A `community_builder:htmlEditor` (Rich Content Editor) runs `richTextValue` through a sanitizer that **strips `<style>` blocks** and **strips `class=` references that resolve against global CSS**. Only this survives:
- DOM structure (`<div>`, `<header>`, `<section>`, `<a>`, …)
- inline `style="..."` attributes
- `class=""` is preserved in DOM but with no matching rules

**Author every CSS rule inline** as `style="..."` on each element. Don't use `<style>` tags; don't rely on `class=` for styling. Use `style="background-image: url(...)"` for icons, or emoji for simple icons.

## `sf project deploy` does NOT replace media-backed CSS files
Files like `sfdc_cms__styles/styles_css/styles.css` ship as **ContentVersions tied to internal IDs** (e.g. `0sNak00000...`). `sf project deploy` reports success but the file is **not actually replaced** — the site keeps loading the original stub. Don't bother editing this file via SFDX. Use the **Site Builder UI** for site-wide CSS, OR keep all styles inline in the htmlEditor.

## Deploy ≠ live — you must publish
After deploying a `DigitalExperienceBundle`, the **draft** is updated but nothing is live until:
```bash
sf community publish --name "<Site Display Name>" -o <alias>
```
Then wait ~20s before re-fetching to confirm the live HTML reflects the change.

## Packaging note
For unlocked-package builds, `DigitalExperienceBundle` is often `.forceignore`-d (2GP rejects "not compatible with site workspaces"). Facilitators deploy it separately via `sf project deploy start`.

## Reference impl
- All-inline-style HTML: `oil-and-gas-workshop-2/scripts/site-html-source.html`
- Idempotent injection into `home/content.json`: `oil-and-gas-workshop-2/scripts/inject-site-html.js`

## Related

- Opening a site as admin via Setup → All Sites (auth-bound link) → `docs/salesforce-browser-automation.md`
- Experience Cloud branding color format (hex not rgb) → `docs/salesforce-core-gotchas.md`
