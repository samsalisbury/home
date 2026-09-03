#!/bin/bash
# PostToolUse(Edit|Write) hook: format markdown with prettier,
# matching the conform.nvim setup so files look the same whether
# Claude or neovim last touched them.
#
# Config resolution: prefer a config discovered from the file's
# own directory (so a project's .prettierrc wins), and fall back
# to ~/.prettierrc.yml when the file lives outside any project
# that defines one.
#
# Always exits 0 — a formatting failure must never block a write.

FILE=$(jq -r '.tool_input.file_path // empty' 2>/dev/null)
[ -z "$FILE" ] && exit 0

case "$FILE" in
*.md | *.markdown | *.mdx) ;;
*) exit 0 ;;
esac

[ -f "$FILE" ] || exit 0

PRETTIER=$(command -v prettier 2>/dev/null)
[ -z "$PRETTIER" ] && [ -x /opt/homebrew/bin/prettier ] &&
  PRETTIER=/opt/homebrew/bin/prettier
[ -z "$PRETTIER" ] && exit 0

if "$PRETTIER" --find-config-path "$FILE" >/dev/null 2>&1; then
  "$PRETTIER" --write "$FILE" >/dev/null 2>&1
elif [ -f "$HOME/.prettierrc.yml" ]; then
  "$PRETTIER" --config "$HOME/.prettierrc.yml" \
    --write "$FILE" >/dev/null 2>&1
fi

exit 0
