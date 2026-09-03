#!/bin/bash
# Blocks network-capable commands for read-only analysis agents.
# Used as a PreToolUse(Bash) hook in agent frontmatter.
# Exit 0 = no decision (normal permission flow). Exit 2 = block.

COMMAND=$(jq -r '.tool_input.command // empty')
[ -z "$COMMAND" ] && exit 0

# Any bare word matching a network-capable binary blocks the call.
# Deliberately over-broad: these agents have no legitimate need for egress.
BLOCKED='curl|wget|nc|ncat|netcat|telnet|ssh|scp|sftp|rsync|ftp|http|https|httpie|xh|aria2c|socat|openssl'

if printf '%s' "$COMMAND" | grep -Eqw "$BLOCKED"; then
  jq -n --arg cmd "$COMMAND" '{
    hookSpecificOutput: {
      hookEventName: "PreToolUse",
      permissionDecision: "deny",
      permissionDecisionReason: ("Network access is blocked for this agent. It analyses local files only. Blocked command: " + $cmd + ". Report back that the data must be fetched by the caller and saved to a file first.")
    }
  }'
  exit 2
fi

# git subcommands that reach the network
if printf '%s' "$COMMAND" | grep -Eq '\bgit\b.*\b(clone|fetch|pull|push|remote +(add|set-url)|ls-remote|submodule)\b'; then
  echo "Network-capable git subcommand blocked for this agent (local analysis only)." >&2
  exit 2
fi

exit 0
