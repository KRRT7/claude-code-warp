#!/bin/bash
# Warp notification utility using OSC escape sequences
# Usage: warp-notify.sh <title> <body>

TITLE="${1:-Notification}"
BODY="${2:-}"

# OSC 777 format: \033]777;notify;<title>;<body>\007
OSC_PAYLOAD=$(printf '\033]777;notify;%s;%s\007' "$TITLE" "$BODY")

CLI_AGENT_SEND="${WARP_CLI_AGENT_SEND:-}"
if [ -n "$CLI_AGENT_SEND" ] && [ -x "$CLI_AGENT_SEND" ] && [ -n "${WARP_CLI_AGENT_IPC:-}" ] && [ -n "${WARP_CLI_AGENT_TOKEN:-}" ]; then
    (printf "%s" "$BODY" | "$CLI_AGENT_SEND" "$TITLE") 2>/dev/null || true
elif [ -n "${WARP_CLI_AGENT_IPC:-}" ] && [ -n "${WARP_CLI_AGENT_TOKEN:-}" ] && command -v warp-cli-agent-send >/dev/null 2>&1; then
    (printf "%s" "$BODY" | warp-cli-agent-send "$TITLE") 2>/dev/null || true
else
    # Write directly to /dev/tty to ensure it reaches the terminal.
    (printf "%s" "$OSC_PAYLOAD" > /dev/tty) 2>/dev/null || true
fi
