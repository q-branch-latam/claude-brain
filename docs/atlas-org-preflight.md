---
name: Atlas Org Preflight & Provisioning
description: Verify an org actually runs Agent Script/Atlas BEFORE building (empty bundle list ≠ unsupported; only INVALID_TYPE means absent). Where to get Atlas trial orgs; enabling toggles on fresh OrgFarm orgs.
last_verified: 2026-06-19
tags: [agentforce, atlas, orgfarm, preflight, provisioning]
authored_with: claude-sonnet-4-6
last_verified_with: claude-sonnet-4-6
---

# Atlas Org Preflight & Provisioning

Open this for: picking/verifying an org for Agentforce v2 / Agent Script work, or "INVALID_TYPE: AiAuthoringBundle" errors.

## Run this FIRST, before any build

Before assuming a pool org is Atlas-capable, verify — pool **aliases mislead** (e.g. `Kenton-and-Pronto-Oil-and-Gas-2` was a Pronto Service Cloud template with 94 custom objects + 1,479 ApexClasses + 3 sites, NOT Agentforce NOW). Skipping the 5-minute check cost a multi-hour overnight rework on 2026-05-07.

**The definitive check** (do this, not the bundle-list check):
```bash
sf org list metadata-types -o <alias> --json   # grep metadataObjects[].xmlName for AiAuthoringBundle
```
If `AiAuthoringBundle` appears in `xmlName`, the org **CAN** run Agent Script / Atlas agents.

Or via tooling API:
```bash
sf data query --json --use-tooling-api -q "SELECT Count() FROM AiAuthoringBundleDefVer" -o <alias>
```
- Returns a count (even 0) → Atlas provisioned, `sf agent preview` will work.
- Returns `INVALID_TYPE` → Atlas runtime missing, do NOT use for Agent Script.

### CRITICAL nuance — empty ≠ unsupported
An **empty** `sf org list metadata -m AiAuthoringBundle` result does **NOT** mean not-Atlas-capable. Empty just means "no Agent Script bundles authored yet." **Only `INVALID_TYPE` means the feature is absent.** (2026-06-03: `sales-amplifier-pronto-org` returned EMPTY for the bundle list but DOES support `AiAuthoringBundle` — it was built via Agent Script just like the SDO, no classic GenAiPlannerBundle divergence.)

### Sanity-check "freshness"
Count custom objects (`SELECT COUNT() FROM CustomEntityDefinition` via tooling), ApexClasses, and Experience Cloud sites. Anything > 0 means the org is preloaded with a template — investigate before assuming it's clean.

## "INVALID_TYPE" on a FRESH OrgFarm trial = toggles OFF, not wrong org

On a brand-new OrgFarm trial, `INVALID_TYPE: Cannot use: AiAuthoringBundle` usually means **Einstein/Agentforce toggles are off**, not that the org is mis-templated. Enable both (one-time, persists):
- Einstein: `/lightning/setup/EinsteinGPTSetup/home` → "Turn on Einstein" switch.
- Agentforce: `/lightning/setup/EinsteinCopilot/home` → master "Agentforce" switch in the page header (the only enabled-and-unchecked toggle).
Reference scripts (Automotive workshop): `scripts/enable-einstein-agentforce-v2.js`, `scripts/enable-agentforce-agents.js`.

## Where to get an Atlas-capable trial org

OrgFarm PROD → Einstein Generative AI product → farms named `Agentforce*`:
- `Agentforce` (post_processor: setupAgentforce), `Agentforce With Digital Wallet DC` (CDP), `Agentforce Vibes (AFV) - TDX` (CDP), `EinsteinSDR`.
- Portal: https://orgfarm.salesforce.com

**Contacts / channels:** `#agentforce-now-in-a-box` (SE workshop channel), `@Stephan Chandler-Garcia` (Agentforce NOW template owner, TTID `0TTKj000003HA9m`), `#orgfarm-farmers-chefs` (infra), `@Naresh Polu` / `@epic-orgfarm-oncall`.

**TSO constraints (if building a template):** TSO cannot be DEMO/FREE type (pool gets zeroed); Data Cloud CANNOT be in the TSO (breaks child DC — use `is_cdp_enabled: true` to provision fresh); `TrialforceTemplateMaxLength` must be non-zero (typically 30 days); TSO must stay active or template breaks (T-0004).

## Related

- Logging into fresh OrgFarm orgs (MFA + phone interstitial) → `docs/org-and-tooling-reference.md`
- Builder navigation once Atlas is confirmed → `docs/agentforce-builder-navigation.md`
