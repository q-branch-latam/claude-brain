---
name: Agentforce Metadata & Deploy
description: Agentforce metadata conventions (GenAiPlannerBundle vs old, deploy manifests) + runtime/deploy gotchas (SYSTEM_MODE DML, ID validation, publish blockers, Instructions truncation).
last_verified: 2026-06-19
tags: [agentforce, metadata, deploy, apex, agent-script]
authored_with: claude-sonnet-4-6
last_verified_with: claude-sonnet-4-6
---

# Agentforce Metadata & Deploy

Open this for: authoring/deploying Agentforce agents, writing Apex actions, or hitting `sf agent publish` errors.

## Metadata conventions

- **New Builder agents** use `GenAiPlannerBundle` (composite XML with embedded topics/actions).
- **Old Builder agents** use separate `GenAiPlannerDefinition` + `GenAiPluginDefinition` + `GenAiFunctionDefinition`.
- **Deploy manifests:** list **Bot + BotVersion + GenAiPlannerBundle only** — never list the embedded functions.
- Always **omit `<channels>`** from cloned Bot XML (workspace convention).
- **API 66.0 minimum** for GenAiPlannerBundle support.
- `<genAiPlannerName>` in BotVersion must **exactly match** the bundle DeveloperName.
- **Service Agents** (`AgentforceServiceAgent`/`EinsteinServiceAgent`) require `default_agent_user` in the agent config; **Employee Agents** (`AgentforceEmployeeAgent`/`InternalCopilot`) must NOT have one. Omitting `agent_type` on an Agent Script bundle defaults it to `EinsteinServiceAgent`, which then fails `sf agent preview` with *"Default agent user is required for the agent type EinsteinServiceAgent."* → **declare `agent_type` explicitly.**

## Apex action gotchas (runtime correctness)

- **DML must use `Database.insert/update(record, AccessLevel.SYSTEM_MODE)`** — NOT `insert as user`. `as user` enforces FLS even in `without sharing` classes; Agentforce running users usually lack FLS on custom objects → `FIELD_INACCESSIBLE` at runtime.
- **Validate Salesforce IDs** in every `@InvocableMethod` that takes an ID. The LLM passes placeholders like `"user_provided_id"`, `"Charles Green"`, `"12345"` → `Database.insert` throws "Invalid id". Add `isValidSalesforceId(String id)` (15 or 18 alphanumeric chars) and fall back to a known demo ID.
- **Don't mark ID fields `required`** in GenAiFunction input schemas. If required and the LLM can't resolve it, the agent asks the user for their Salesforce ID (terrible UX). Use a fallback demo ID in Apex.
- **`genAiPluginInstructions` (topic-level) override knowledge search.** A single "You are not a medical doctor" guardrail blocks all KB answers because instructions are applied before KB results are evaluated. For domain agents, rewrite topic instructions in domain language and explicitly permit factual KB answers.
- **DataSpace membership cannot be set via metadata** — add the agent user in Setup → Data Spaces → [space] → Members manually.

## Publish blockers (the ones that cost hours)

### `sf agent publish` can't resolve `@knowledge.rag_feature_config_id`
Fails with `Invalid ragFeatureConfigIds: [@knowledge.rag_feature_config_id]` whenever the `.agent` contains an `AnswerQuestionsWithKnowledge` (AQWK) action using `@knowledge.*` token defaults — the CLI sends the literal token instead of resolving it.

**Fix:** Strip ONLY the AQWK action (and its FAQ-topic reference) from `.agent` source, but **KEEP the agent-level `knowledge:` block**. CLI publish + activate. Then add AQWK back via the **new Builder** (FAQ subagent → Add Action → "Answer Questions with Knowledge" → defaults → Commit). Builder resolves `@knowledge.*` correctly because the block exists.
- **Critical:** if you ALSO strip the `knowledge:` block, the Builder-added AQWK throws 6 "Unknown @knowledge field" errors and won't commit. The block MUST stay.
- For workshops this is a teaching moment — students wire RAG in Builder rather than getting it preconfigured.
- If `aiAuthoringBundles/` is `.forceignore`d, publish returns `ComponentSetError: No source-backed components present`. Temporarily un-ignore, publish + activate, then restore.

### `sf agent publish` ComponentSetError on packaging projects
Exits **code 1** with `ComponentSetError: No source-backed components present in the package` when `sfdx-project.json` has a `packageAliases` entry (a `0Ho` ID). **But publish SUCCEEDS server-side** — the CLI writes `<target>...vNN</target>` back to bundle-meta.xml. Verify with `sf agent activate --api-name <DevName>` (it reports the new version). **Do NOT retry** — each retry creates a new locked version in the org.

### Instructions field silently truncates >~140 chars
The new Builder **Reasoning Instructions** field clips any prose line beyond ~140 chars on Save — no error, no warning. Persisted metadata stops mid-word ("...al usuario — nunc"). The agent then runs with broken reasoning.
- **Fix:** hard-wrap every instruction line to ≤140 chars; use bullet/list format with newlines, not flowing paragraphs.
- **Verify** by retrieving: `sf project retrieve start -m AiAuthoringBundle:<DevName>` and reading the `.agent` — truncation shows as lines ending mid-word. Don't trust the Builder display (it echoes the truncated text faithfully).
- Reference inline actions with `{!@actions.<API_Name>}`.

## Related

- Atlas capability preflight → `docs/atlas-org-preflight.md`
- New Builder UI/wizard navigation → `docs/agentforce-builder-navigation.md`
- More Salesforce platform gotchas (profiles, tabs, layouts) → `docs/salesforce-core-gotchas.md`
