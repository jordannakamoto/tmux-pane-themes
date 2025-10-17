#!/usr/bin/env bash

# Show themes submenu
CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/tmux-pane-themes"
PALETTE_FILE="$CACHE_DIR/palette.conf"

# Build menu items array
# Position at mouse location
menu_args=(-T "#[align=centre]Select Theme" -x M -y M)

# Add pinned themes
if [ -f "$PALETTE_FILE" ] && [ -s "$PALETTE_FILE" ]; then
    while IFS='|' read -r slot theme_name display_name; do
        [ -z "$slot" ] && continue
        # Escape theme names with spaces for the shell command
        menu_args+=("$display_name" "$slot" "run-shell \"$CURRENT_DIR/apply-theme.sh \\\"$theme_name\\\"\"")
    done < <(sort -n "$PALETTE_FILE")
fi

# Add separator and picker
menu_args+=("" "Browse All Themes..." "t" "run-shell \"tmux popup -E -w 80% -h 80% $CURRENT_DIR/theme-picker.sh\"")

# Execute the menu
tmux display-menu "${menu_args[@]}"
