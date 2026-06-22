#!/bin/bash
# session-end-capture.sh — Stop-hook nudge for the claude-brain knowledge base.
#
# Non-intrusive reminder: if this session likely produced durable learnings,
# remind the user to run /capture. Hooks run non-interactively and MUST NOT
# write anything — /capture does the approve-before-write work. This only nudges.
#
# Wiring: add as a second entry in the existing "Stop" hooks array in
# ~/.claude/settings.json (MERGE — do not overwrite the telemetry/stop-hook
# entries). See procedure/SETUP.md.
#
# Output contract: a single line of JSON with a "systemMessage" key, which
# Claude Code surfaces to the user. Emitting nothing = silent.

# Read the hook payload (Stop hooks receive JSON on stdin); we don't need it,
# but draining stdin avoids a broken pipe.
cat >/dev/null 2>&1

# A gentle, always-on reminder. Kept short so it doesn't add noise.
printf '%s\n' '{"systemMessage":"💡 If this session produced durable learnings (a gotcha that took retries, a prompt that worked, a tooling quirk), run /capture to add them to claude-brain — it will propose entries for you to approve before writing."}'

exit 0
