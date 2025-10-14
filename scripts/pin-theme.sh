#!/usr/bin/env bash

# Pin a theme to a palette slot and update tmux.conf
CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
THEMES_DIR="$CURRENT_DIR/../themes"
CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/tmux-pane-themes"

mkdir -p "$CACHE_DIR"

if [ -z "$1" ] || [ -z "$2" ]; then
    echo "Usage: $0 <theme-name> <slot-number>"
    exit 1
fi

THEME_NAME="$1"
SLOT="$2"

# Load theme colors
get_theme_line() {
    local theme="$1"

    # Check built-in themes
    if [ -f "$THEMES_DIR/builtin.conf" ]; then
        grep "^$theme|" "$THEMES_DIR/builtin.conf" && return
    fi

    # Check custom themes
    if [ -f "$CACHE_DIR/custom-themes.conf" ]; then
        grep "^$theme|" "$CACHE_DIR/custom-themes.conf"
    fi
}

THEME_LINE=$(get_theme_line "$THEME_NAME")

if [ -z "$THEME_LINE" ]; then
    echo "Error: Theme '$THEME_NAME' not found"
    exit 1
fi

DISPLAY_NAME=$(echo "$THEME_LINE" | cut -d'|' -f3)

# Store the pinned theme
PALETTE_FILE="$CACHE_DIR/palette.conf"
touch "$PALETTE_FILE"

# Remove existing entry for this slot
sed -i.bak "/^$SLOT|/d" "$PALETTE_FILE" 2>/dev/null || true

# Add new entry
echo "$SLOT|$THEME_NAME|$DISPLAY_NAME" >> "$PALETTE_FILE"

# Update tmux.conf right-click menu
"$CURRENT_DIR/update-tmux-menu.sh"
