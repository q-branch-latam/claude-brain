---
name: Agentforce Builder Navigation (NEW vs OLD)
description: Atlas orgs have TWO Agentforce builders. Always use the new Builder direct URL; the actual New Agent wizard shape (Skip Ahead); editing published agents; loading the developing-agentforce skill.
last_verified: 2026-06-19
tags: [agentforce, builder, ui, navigation, atlas]
authored_with: claude-sonnet-4-6
last_verified_with: claude-sonnet-4-6
---

# Agentforce Builder Navigation (NEW vs OLD)

Open this for: navigating Agentforce Builder, the "+ New Agent" wizard, or guiding/automating the v2 workshop UI.

## TWO builders — never confuse them

In Atlas-capable orgs there are two completely different Agentforce builders at different URLs. **Modern (v2 / Agent Script) work uses the NEW one exclusively.**

- **NEW Builder (Agent Script, IDE-style)** — direct URL:
  `https://<lightning-host>/lightning/n/standard-AgentforceStudio?c__nav=agents`
  Sidebar: **Build** (Agents/Tests/Prompt Templates/Data/AI Models/Agentforce DX) + **Observe** (Analytics/Optimization). Agents open in an IDE canvas (Explorer tree, Subagents node, System block). This is what guides call "Agentforce Studio".
- **OLD Setup page (legacy Topic-based)** — `https://<setup-host>/lightning/setup/EinsteinCopilot/home`. Setup chrome, Quick Find, old Topic wizard. Has a blue "Let's Go" card to the new Builder. **Do NOT route through this** — the Setup-host vs lightning-host swap, popup handling, and tab handoff all add fragility.

**Why this matters:** Sonnet has repeatedly read "Setup → Agentforce Studio" literally and stayed on the OLD Setup page during v2 workshop runs (2026-05-09), then mishandled the popup and clicked the wrong button. Going straight to the new Builder URL avoids all of it.

## The actual "+ New Agent" wizard (3 screens, simpler than old docs say)

1. **"What do you want your agent to do?"** — top textbox (AI-generated path — **non-deterministic, DO NOT USE for workshops**) + template cards. Click **Select** on the template (e.g. Service Agent), not *Details*.
2. **"Name your agent" modal** — Agent Name, auto-derived Developer Name, and **Agent's User Record** (New User / **Select User**). For Service Agents the Select User dropdown shows ONE option: `EinsteinServiceAgent User (agentforce_service_agent.<hash>@example.com)` — the admin user is NOT eligible, and the hash is per-org (can't hardcode). Click **Let's Go** (not "Create"/"Next").
3. **Builder loads** → click **Skip Ahead** for a deterministic empty agent. Skip Ahead leaves exactly 4 mandatory plumbing subagents: `Agent Router`, `Escalation`, `Off Topic`, `Ambiguous Question` — leave them.

**Not in the wizard** (despite older Guía drafts): no "deselect General FAQ" step, no Description field, no Topic List field. Description is set AFTER creation in the Agent Definition canvas.

## Editing a published agent

To edit a published/activated agent in the new Builder you must first **deactivate** it and **create a new draft version**. Never instruct "click Save + Publish" without confirming draft state first.

## Skill discipline

Always load the **`developing-agentforce` skill BEFORE giving any Builder UI navigation guidance.** Going from training-data memory produces OLD-builder steps (this happened with the Data Library → FAQ topic attach flow). The skill references describe the current UI.

## Playwright automation notes

- Dismiss the "Try the new Field Service Setup" popup (`button:has-text("Dismiss")`) on first load before any clicks, or it intercepts wizard buttons.
- "+ New Agent" is a split button with a ▾ chevron. Match exact `textContent.trim() === 'New Agent'`; `:has-text("New Agent")` may hit the chevron.
- Wizard inputs live inside `agentAuthoringBuilder.app` LWC shadow roots. Use `evaluate()` shadow walks; top-level `page.locator('input')` returns 0.

## Related

- Metadata/publish behavior → `docs/agentforce-metadata-and-deploy.md`
- General Salesforce browser automation → `docs/salesforce-browser-automation.md`
- Enabling Einstein/Agentforce toggles on a fresh org → `docs/atlas-org-preflight.md`
