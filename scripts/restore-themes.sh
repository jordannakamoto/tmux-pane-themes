#!/usr/bin/env bash

# Restore saved themes for all panes
CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
THEMES_DIR="$CURRENT_DIR/../themes"
CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/tmux-pane-themes"
THEME_FILE="$CACHE_DIR/pane-themes"

# Exit if no saved themes
[ ! -f "$THEME_FILE" ] && exit 0

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

# Get list of current panes
current_panes=$(tmux list-panes -a -F '#{pane_id}')

# Restore theme for each pane that still exists
while IFS=: read -r pane_id theme_name; do
    [ -z "$pane_id" ] && continue

    # Check if pane still exists
    if echo "$current_panes" | grep -q "^$pane_id$"; then
        colors=$(get_theme_colors "$theme_name")

        if [ -n "$colors" ]; then
            tmux select-pane -t "$pane_id" -P "$colors" 2>/dev/null
        fi
    fi
done < "$THEME_FILE"

# Clean up entries for panes that no longer exist
temp_file=$(mktemp)
while IFS=: read -r pane_id theme_name; do
    if echo "$current_panes" | grep -q "^$pane_id$"; then
        echo "$pane_id:$theme_name" >> "$temp_file"
    fi
done < "$THEME_FILE"
mv "$temp_file" "$THEME_FILE"
