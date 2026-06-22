---
name: SFDX Metadata & Packaging Gotchas
description: ContentAsset folder-per-asset layout for packaging; OmniStudio/OmniScript deploy gotchas; FSC managed→platform Flow translation; Action Launcher + FlexiPage wiring.
last_verified: 2026-06-19
tags: [sfdx, metadata, packaging, contentasset, omnistudio, fsc, flow]
authored_with: claude-sonnet-4-6
last_verified_with: claude-sonnet-4-6
---

# SFDX Metadata & Packaging Gotchas

Open this for: SFDX source-format layout issues, `sf package version create` failures, OmniStudio/OmniScript deploys, or translating FSC managed metadata to platform-standard.

## ContentAsset — folder-per-asset layout (packaging is stricter than deploy)
ContentAssets in SFDX source format must use a **folder-per-asset** layout:
```
force-app/main/default/contentassets/
  My-Asset-Name/
    My-Asset-Name.asset-meta.xml
    My-Asset-Name.pdf            # or .png/.jpg
```
**NOT** loose siblings (`My-Asset-Name.asset-meta.xml` + `My-Asset-Name.pdf` directly under `contentassets/`). The loose layout fails `sf package version create` with `ExpectedSourceFilesError: Expected source files for type 'ContentAsset'` — even though `sf project deploy` may tolerate it. The `.asset-meta.xml`'s `<pathOnClient>`/`<zipEntry>` reference the binary filename only (no path prefix).

## OmniScript authoring (validated on ASSIST-110258)
- **Valid element `<type>` values:** `Text`, `Text Area`, `Select`, `Radio`, `Currency`, `Number`, `Date`, `Datepicker`, `Checkbox Group`, `Display Text`, `Lookup`, `File`, `Step`, `Block`, `Set SObject Property`.
- **Invalid** (throw "bad value for restricted picklist"): `Multi-line Text`, `Email`, `Checkbox`.
- `<description>` max 255 chars — longer → "data value too large".
- `propertySetConfig` is XML-encoded JSON. Any unescaped `"` inside HTML content (e.g. `the "Agreement"`) silently breaks the whole deploy with "Invalid property set" (no line number). Validate before each deploy: `python3 scripts/validate-os-json.py <os-file>`.
- `<defaultSelectedChoiceReference>` must name a specific choice **node**, NOT the choiceSet developer name → else "unexpected error".
- "Invalid property set" could be any of the above — run the validator before retrying.

## Action Launcher + FlexiPage wiring
- `ActionLauncherItemDef` resolves OmniScripts at runtime by `(type, subType, itemLanguage)` tuple, NOT DeveloperName. Verify: `sf data query -q "SELECT Id FROM OmniProcess WHERE Type='OmniScript' AND SubType='<subType>' AND Language='<lang>' AND IsActive=true"`.
- FlexiPage `deploymentId` takes the **DeveloperName** of the `RecordActionDeployment`, not label/Id.
- `versionNumber` in `ActionLauncherItemDef` is optional for OmniScripts (resolves to active version).
- OmniStudio `/lightning/n/OmniStudio` returns "Page doesn't exist" where OmniStudio is platform (not managed) — navigate by `OmniProcess` record Id instead.

## FSC managed → platform-standard Flow translation
- Platform-standard `FinancialAccountTransaction` fields: `Amount`, `Description`, `TransactionDate`, `Type`, `SubType`, `FinancialAccountNumber` — no `__c`, no `FinServ__`.
- `builder_industries_insurance:fscSinglTbl`/`fscMultiTbl` are managed LWC screen components — absent without the FSC package. Replace with `RadioButtons` + `dynamicChoiceSet`, and `DisplayText` respectively.
- `FinServFlowsExt__` managed gateway subflows won't deploy on a non-FSC dest — drop them, rewire directly to the next element.
- `runtime_appointmentbooking` managed screens ARE present on modern FSC orgs without the legacy package — verify before dropping: `SELECT DurableId FROM FlowDefinitionView WHERE ApiName LIKE 'runtime_appointmentbooking%'`.

## Related

- Apex/agent platform gotchas → `docs/salesforce-core-gotchas.md`
- Agentforce metadata specifics → `docs/agentforce-metadata-and-deploy.md`
