#!/usr/bin/env bash
# Ensures shell customizations (pyenv/rbenv init, aliases) are present in
# ~/.zshrc. Runs on every container start via postStartCommand, since
# ~/.zshrc lives on a persistent named volume (see devcontainer.json) that
# survives image rebuilds — appending these lines in the Dockerfile only
# affects fresh volumes, not ones created before the lines were added.
set -euo pipefail

ZSHRC="$HOME/.zshrc"

START_MARKER="# BEGIN devcontainer-managed (Dockerfile-driven; do not edit manually)"
BODY=$(cat <<'EOF'
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PYENV_ROOT/shims:$PATH"
eval "$(pyenv init -)"
export RBENV_ROOT="/usr/local/share/rbenv"
export PATH="$RBENV_ROOT/bin:$RBENV_ROOT/shims:$PATH"
eval "$(rbenv init -)"
alias dcr='dc run --rm'
EOF
)
END_MARKER="# END devcontainer-managed"

touch "$ZSHRC"

# Drop any previously written managed block so this stays idempotent.
awk -v start="$START_MARKER" -v end="$END_MARKER" '
    $0 == start { skip = 1; next }
    $0 == end { skip = 0; next }
    !skip { print }
' "$ZSHRC" > "$ZSHRC.tmp"
mv "$ZSHRC.tmp" "$ZSHRC"

# Re-append the managed block, fenced by the markers so future runs can find
# and replace it.
{
    echo "$START_MARKER"
    echo "$BODY"
    echo "$END_MARKER"
} >> "$ZSHRC"
