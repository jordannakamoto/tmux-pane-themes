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

# Fetch and convert iTerm2 theme
fetch_iterm2_theme() {
    local theme="$1"
    local temp_file="/tmp/${theme}.itermcolors"

    # Download the .itermcolors file
    curl -s "https://raw.githubusercontent.com/mbadolato/iTerm2-Color-Schemes/master/schemes/${theme}.itermcolors" -o "$temp_file"

    if [ ! -f "$temp_file" ]; then
        return 1
    fi

    # Convert using our converter script
    local colors=$("$CURRENT_DIR/convert-iterm2-theme.sh" "$temp_file" 2>/dev/null)
    rm -f "$temp_file"

    if [ -n "$colors" ]; then
        # Cache the converted theme
        mkdir -p "$CACHE_DIR"
        echo "$theme|$colors|$theme" >> "$CACHE_DIR/custom-themes.conf"
        echo "$colors"
        return 0
    fi

    return 1
}

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

    # Try to fetch as iTerm2 theme
    colors=$(fetch_iterm2_theme "$theme")
    [ -n "$colors" ] && echo "$colors" && return
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

# Don't restart shell if called from picker (it will exit cleanly)
# Only restart shell if called directly (e.g., from right-click menu)
if [ -z "$FROM_PICKER" ] && [ -n "$TMUX" ]; then
    TMUX_PANE_THEME="$THEME_NAME" exec $SHELL
fi
