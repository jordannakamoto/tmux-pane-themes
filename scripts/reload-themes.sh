#!/usr/bin/env bash

# Helper script to reload themes list with updated palette header
# Used by fzf's reload binding

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
THEMES_DIR="$CURRENT_DIR/../themes"
CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/tmux-pane-themes"

# Generate header with palette
generate_header() {
    local PALETTE_FILE="$CACHE_DIR/palette.conf"
    echo "━━━━━━━━━━ PALETTE ━━━━━━━━━━"

    if [ -f "$PALETTE_FILE" ] && [ -s "$PALETTE_FILE" ]; then
        while IFS="|" read -r slot theme_name display_name; do
            [ -z "$slot" ] && continue
            printf "[%s] %-20s\n" "$slot" "$display_name"
        done < <(sort -n "$PALETTE_FILE")
    else
        echo "(press 1-9 to pin themes)"
    fi

    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
}

# Load available themes
load_themes() {
    # Load built-in themes
    if [ -f "$THEMES_DIR/builtin.conf" ]; then
        cat "$THEMES_DIR/builtin.conf" | grep -v '^#' | grep -v '^$'
    fi

    # Load iTerm2 themes
    if [ -f "$THEMES_DIR/iterm2.conf" ]; then
        cat "$THEMES_DIR/iterm2.conf" | grep -v '^#' | grep -v '^$'
    fi

    # Load custom themes if they exist
    if [ -f "$CACHE_DIR/custom-themes.conf" ]; then
        cat "$CACHE_DIR/custom-themes.conf" | grep -v '^#' | grep -v '^$'
    fi
}

# Output header + themes
generate_header
load_themes | sort -t'|' -k3
