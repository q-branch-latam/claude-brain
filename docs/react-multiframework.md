---
name: React.js / Salesforce Multi-Framework (UIBundle)
description: Building React apps deployed to Salesforce via Multi-Framework (UIBundle) — org gating, Apex REST proxy for guest/Experience data, embedding agents (ACC vs MIAW), the 3-pass skill workflow, CLI gotchas, build hygiene.
last_verified: 2026-06-19
tags: [react, multiframework, uibundle, experience-cloud, miaw, apex-rest]
authored_with: claude-sonnet-4-6
last_verified_with: claude-sonnet-4-6
---

# React.js / Salesforce Multi-Framework — Building Guide

Open this for: building/deploying a React app to Salesforce via Multi-Framework (UIBundle), embedding an agent in it, or guest/Experience-site data-access failures. Durable learnings from the Pronto customer loyalty portal demo.

## The Org Environment

**Multi-Framework availability (as of June 2026):** reached "Accelerated" soft-GA on 2026-06-03. It is:
- **Self-serve in sandboxes and scratch orgs** (Setup → Multi-Framework toggle).
- **Blacktab-gated in production/demo orgs** (needs internal "God"-level access to enable).
- **Cannot be disabled once enabled.**
- **Requires org default language `en_US`.**

**Partial Copy sandboxes:** cloning a prod org clones data/config but **NOT feature licenses** — re-enable Multi-Framework, Digital Experiences, and Einstein/Agentforce in Setup after creation.

## Wall 1: Guest / Experience Site Data Access

**Symptom:** the deployed React portal renders but every data call fails with `401 INSUFFICIENT_ACCESS "This feature is not currently enabled for this user"` — even loaded by an authenticated admin.

**Root cause:** UI API and GraphQL are **NOT available to guest users or on Experience Cloud surfaces** in the Multi-Framework Beta. The *surface* is gated, not the data — the identical GraphQL query works against the **standard org endpoint** with a bearer token, but through the site proxy → 401.

**The fix — Apex REST proxy:**
1. Thin Apex REST endpoint (the class itself is the access boundary):
   ```apex
   @RestResource(urlMapping='/yourthing/dashboard/*')
   global without sharing class YourApiClass {
       @HttpGet
       global static YourDTO getDashboard() {
           // read-only, fixed minimal field set, bound SOQL only
       }
   }
   ```
2. Call from React via the Data SDK:
   ```ts
   const sdk = await createDataSDK();
   const res = await sdk.fetch?.('/services/apexrest/yourthing/dashboard?name=...', { method: 'GET' });
   ```
3. Use `without sharing` deliberately: Contact OWD is typically Private and guest Contact sharing rules aren't permitted, so the Apex class is the read-only gate (fixed fields, safe params only).
4. Grant the class on the guest/portal permission set via `<classAccesses>`.
5. Keep the GraphQL version commented as a one-line swap for when the Beta gate lifts.

**Why it works:** `/services/apexrest/...` is on the Data SDK allow-list for guest, authenticated, and local dev users.

## Wall 2: Embedding Agents — Two Different Paths

**Check the agent type first:** `sf data query -q "SELECT DeveloperName, Type FROM BotDefinition WHERE DeveloperName='<YourAgent>'"`

### Employee Agents (internal apps)
- Use **Agentforce Conversation Client** (`@salesforce/ui-bundle-template-feature-react-agentforce-conversation-client`), `createAccWidget()`.
- Requirements: My-Domain cookie policy + Trusted Domains for Inline Frames. Context: internal apps, Lightning Out 2.0.

### Service Agents (customer-facing public sites)
- Agent type `EinsteinServiceAgent` / `ExternalCopilot`. Use **MIAW (Messaging for In-App & Web / Enhanced Chat)**.
- **Most of the chain is metadata-deployable:** `QueueRoutingConfig` + `Queue` (object = MessagingSession); a **RoutingFlow** (`processType=RoutingFlow`) with `routeWork` (`routingType=Copilot`, `copilotId` via `<setupReference><setupReferenceType>BotDefinition</setupReferenceType>` = agent dev name — PORTABLE, no hardcoded ID; `serviceChannelId` via setupReference to `sfdc_livemessage`; fallback `queueId`; `<status>Active</status>`); a `MessagingChannel` (`messagingChannelType=EmbeddedMessaging`, `sessionHandlerType=Flow`, `sessionHandlerFlow`+`sessionHandlerQueue`); a `CorsWhitelistOrigin` with the EXACT site origin.
- **Setup-only steps:** enable Omni-Channel; **activate** the messaging channel (deploys Inactive, no metadata field); create the Embedded Service Deployment (New → **Enhanced Chat** = MIAW); add site origin; **Switch to V2** (needed for inline); Publish; copy the 4 `init(...)` values into config.
- **Embed in React:** load the ESW bootstrap, `init(orgId, deploymentName, eswBaseUrl, { scrt2URL })`. For an **inline panel** (ECv2 only): `boot.settings.displayMode='inline'` + `boot.settings.targetElement=<div>` + `headerEnabled=false`. Files: `src/components/YourChat.tsx`, `src/config/miaw.ts`.

**Gotchas (each distinct):**
- `428 "Messaging Channel … is not active"` → activate the channel in Setup.
- CORS "No 'Access-Control-Allow-Origin'" from `*.salesforce-scrt.com` → deploy `CorsWhitelistOrigin` with the exact origin.
- Inline chat ~150px tall → force fixed height on the **iframe** (`iframe.embeddedMessagingFrame { height:520px !important }`), not the parent.
- Inline silently ignored → deployment is v1; use **"Switch to V2"**.
- Wrong path: embedding the internal ACC for a Service Agent on a public portal → chat never connects.

Full annotated runbook: `pronto-portal/MIAW-SETUP.md`.

## The Three-Pass Skill Workflow

Dylan Andersen's approach (`https://docs.dylan.tips/salesforce-multi-framework`). Keep `npm run build` green after every pass:
1. **Scaffold + Data** — `/sf-multiframework`: scaffold UIBundle, wire Data SDK, deploy, verify build+deploy.
2. **Visual Design** — `/frontend-design`: layout, hierarchy, polish, branding. DO NOT change the data layer.
3. **React Quality** — `/react-best-practices`: component structure, hooks, effect cleanup (cancellation guards), no barrel imports, split large components. DO NOT change design or data shape.

**Skill install:**
```bash
npx --yes skills add https://github.com/dylandersen/sf-multiframework
npx --yes skills add https://github.com/anthropics/skills --skill frontend-design
npx --yes skills add https://github.com/vercel/vercel-plugin
```
**npm cache note:** EPERM on root-owned `~/.npm` → `sudo chown -R "$(id -u):$(id -g)" "$HOME/.npm"` or `export NPM_CONFIG_CACHE=$(mktemp -d)`.

## CLI Gotchas

- **ObjectPermissions/SetupEntityAccess queries lag after deploy.** `sf project deploy` reports success but SOQL shows zero grants (replication lag). Verify by retrieving metadata instead: `sf project retrieve start -m "PermissionSet:YourPS" -r ./tmp` then `grep -c '<objectPermissions>'`.
- **`sf project retrieve -r` must be inside the SFDX project root**, not an arbitrary path.
- **See access tokens:** `SF_TEMP_SHOW_SECRETS=true`.
- **Reserved word `like`** (the SOQL operator) — don't name a variable `like`; use `searchTerm`.
- **`<classAccesses>` requires the class to exist** — deploy the Apex class in the same deploy as (or before) the permission set, else "no ApexClass named X found".

## Build & Deploy Hygiene

- **`.forceignore`** must exclude `node_modules/`, `src/`, config — only `dist/` deploys, or you hit the UIBundle file/size ceiling.
- **`ui-bundle.json`:** `{ "outputDir": "dist", "routing": { "fallback": "index.html" } }` — NO apiVersion. The `routing.fallback` is critical for deep-link refresh (without it, refresh on `/some/route` → 404).
- **`<app>.uibundle-meta.xml`:** `<isActive>true</isActive>` required; `<target>Experience</target>` for external/public (vs internal); NO `<apiVersion>`.
- **Deploy then publish:** after deploying a `DigitalExperienceBundle`, `sf community publish --name "<Site Display Name>" -o <alias>` — deploy alone only updates the draft.

## The One-Time 401 in Console (harmless)
After moving to the Apex REST proxy you may still see a single `401` on `/services/data/vXX/ui-api/session/csrf` at load. That's the Data SDK probing the gated GraphQL CSRF endpoint during `createDataSDK()`. Your data comes from the Apex endpoint returning `200`; the probe is benign — mention it during demos so it doesn't look like a bug.

## Key Resources
| Resource | URL |
|---|---|
| Dylan Andersen's Multi-Framework docs | `https://docs.dylan.tips/salesforce-multi-framework` |
| Ankit's data-wiring walkthrough | `https://developers-grove-vibe-code-4f97e44b7ce7.herokuapp.com/react-app/wire-salesforce` |
| Trailhead recipes | `https://github.com/trailheadapps/multiframework-recipes` |
| sf-multiframework skill refs | `~/.claude/skills/sf-multiframework/references/` (data-sdk.md, permissions-csp.md, acc-integration.md, troubleshooting.md) |

## The Proof in One Line
Live data works (curl the standard endpoint → record returned) and the *surface* is the gate. The durable answer for any public Salesforce React portal: **read through Apex REST, embed Service Agents through MIAW.** Everything else is hygiene.
