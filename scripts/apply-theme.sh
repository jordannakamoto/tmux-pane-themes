#!/usr/bin/env bash

# Apply theme to current tmux pane
CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
THEMES_DIR="$CURRENT_DIR/../themes"
CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/tmux-pane-themes"
THEME_FILE="$CACHE_DIR/pane-themes"

mkdir -p "$CACHE_DIR"

if [ -z "$1" ]; then
    echo "Usage: $0 <theme-name>"
    exit 1
fi

THEME_NAME="$1"
PANE_ID="${TMUX_PANE}"

# Get current pane if not set (for when called from menu)
if [ -z "$PANE_ID" ]; then
    PANE_ID=$(tmux display-message -p '#{pane_id}')
fi

# Load theme colors
get_theme_colors() {
    local theme="$1"

    # Check built-in themes
    if [ -f "$THEMES_DIR/builtin.conf" ]; then
        colors=$(grep "^$theme|" "$THEMES_DIR/builtin.conf" | cut -d'|' -f2)
        [ -n "$colors" ] && echo "$colors" && return
    fi

    # Check custom themes
    if [ -f "$CACHE_DIR/custom-themes.conf" ]; then
        colors=$(grep "^$theme|" "$CACHE_DIR/custom-themes.conf" | cut -d'|' -f2)
        [ -n "$colors" ] && echo "$colors" && return
    fi
}

COLORS=$(get_theme_colors "$THEME_NAME")

if [ -z "$COLORS" ]; then
    tmux display-message "Error: Theme '$THEME_NAME' not found"
    exit 1
fi

# Store theme for this pane
touch "$THEME_FILE"
sed -i.bak "/^$PANE_ID:/d" "$THEME_FILE" 2>/dev/null || true
echo "$PANE_ID:$THEME_NAME" >> "$THEME_FILE"

# Apply the theme colors to the pane
tmux select-pane -t "$PANE_ID" -P "$COLORS"

# If we're in a shell, restart it with the theme variable
if [ -n "$TMUX" ]; then
    TMUX_PANE_THEME="$THEME_NAME" exec $SHELL
fi
