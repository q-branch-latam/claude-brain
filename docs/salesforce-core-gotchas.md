---
name: Salesforce Core Platform Gotchas
description: Cross-cutting Salesforce deploy/runtime gotchas — LWC @wire reactivity & proxy spread, Experience Cloud hex-not-rgb, SDO profile naming, NAME field in layouts, tab-before-permset ordering, Slack-as-channel constraints.
last_verified: 2026-06-19
tags: [salesforce, lwc, experience-cloud, deploy, slack, apex]
authored_with: claude-sonnet-4-6
last_verified_with: claude-sonnet-4-6
---

# Salesforce Core Platform Gotchas

Open this for: LWC reactivity bugs, Experience Cloud branding deploy errors, profile/tab/layout deploy ordering, or wiring Agentforce into Slack.

## LWC

- **`@wire` reactivity in Experience Cloud facets / record pages:** `@api recordId` may be unset when the wire first evaluates → wire fires with `undefined` and never re-fires. Set a tracked var in `connectedCallback()` first:
  ```js
  connectedCallback() { this._recordId = this.recordId || FALLBACK_ID; }
  @wire(myMethod, { id: '$_recordId' })
  ```
- **Never spread a Proxy object** (`{ ...proxyObject }`) to copy wire results — it silently drops all fields (result looks like `{}`, no error). Explicitly map each field: `data.map(c => ({ field1: c.field1, field2: c.field2 }))`.

## Experience Cloud branding
- **Use hex (`#003087`), not `rgb(0,48,135)`** in ExperienceBundle JSON. Some branding/theme fields treat `rgb()` as a Salesforce object ID reference → deploy error "references an object with the ID value rgb(...)". (For LWR site CSS specifics see `docs/experience-cloud-lwr.md`.)

## Deploy ordering & naming
- **SDO/HLS profile names are prefixed** — the admin profile is `HLS RDO - System Administrator`, not `System Administrator`. Wrong name → "Entity of type 'Profile' cannot be found". Retrieve the actual name (`sf org list metadata`) before assuming standard names.
- **Custom object Name field in page-layout XML is `NAME` (all caps)**, not `Name` — the platform uses `NAME` as the API name of the auto-created Name field. `<relatedLists><fields>NAME</fields>`. Wrong case → "Invalid field".
- **Deploy custom tabs BEFORE permission sets that reference them** — permission set `<tabSettings>` validation fails if the tab doesn't exist yet. (Same pattern: deploy Apex classes before permission sets with `<classAccesses>` — see `docs/react-multiframework.md`.)

## Slack as an Agentforce channel
- The Slack connector is the **`slack-platform-connector` managed package** (auto-provisions the `Slack`/`SlackDev` connected apps) — NOT a hand-built connected app, NOT an AppExchange search. A fresh org needs that package before the agent can be wired to Slack. (An org with "Guided Slack Setup" but 0 connected apps wires Slack-Channels-for-Records, not the Agentforce connector.)
- **Native Slack is an internal employee channel** → use an **Employee Agent** (`AgentforceEmployeeAgent`), not a customer Service Agent.
- **Slack deployment is UI-only** for the connection step: CLI covers author/validate/publish/activate, but the Slack Connection (Builder → Connections → Slack → Activate), Slack admin approval, and adding the agent to a channel have no metadata/CLI path.
- **Slack rendering limits:** Custom Lightning Types do NOT render in Slack/WhatsApp; no markdown tables; no carousels (use text options); text-first responses; add agents as channel **members**, not just via the Agents tab. Native SF↔Slack connection handles up to 200 records simultaneously (vs ~50 for external APIs).

## Related

- Agentforce-specific Apex/metadata (SYSTEM_MODE DML, ID validation, plugin instructions) → `docs/agentforce-metadata-and-deploy.md`
- OmniStudio / FSC / packaging → `docs/sfdx-metadata-gotchas.md`
