#!/usr/bin/env bash

# Interactive theme picker with fzf
CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
THEMES_DIR="$CURRENT_DIR/../themes"
CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/tmux-pane-themes"

# Check if fzf is available
if ! command -v fzf &> /dev/null; then
    tmux display-message "fzf is required for the theme picker. Install with: brew install fzf"
    exit 1
fi

mkdir -p "$CACHE_DIR"

# Fetch iTerm2 themes on-demand
fetch_iterm2_themes() {
    local cache_file="$CACHE_DIR/iterm2-themes.conf"
    local cache_age=86400  # 24 hours

    # Check if cache exists and is fresh
    if [ -f "$cache_file" ]; then
        local age=$(($(date +%s) - $(stat -f %m "$cache_file" 2>/dev/null || stat -c %Y "$cache_file" 2>/dev/null)))
        if [ $age -lt $cache_age ]; then
            cat "$cache_file"
            return
        fi
    fi

    # Fetch theme list from iTerm2-Color-Schemes repo
    tmux display-message "Fetching iTerm2 themes..."

    # Get list of .itermcolors files from GitHub API
    local themes_json=$(curl -s "https://api.github.com/repos/mbadolato/iTerm2-Color-Schemes/contents/schemes")

    # Parse and cache theme names (we'll use placeholders for colors until selected)
    echo "$themes_json" | grep '"name"' | grep 'itermcolors' | sed 's/.*"name": "//g' | sed 's/".*//g' | sed 's/\.itermcolors//g' | while IFS= read -r theme; do
        # Use neutral colors as placeholder
        echo "$theme|bg=#1e1e2e,fg=#cdd6f4|$theme (iTerm2)"
    done > "$cache_file"

    cat "$cache_file"
}

# Load available themes
load_themes() {
    # Load built-in themes
    if [ -f "$THEMES_DIR/builtin.conf" ]; then
        cat "$THEMES_DIR/builtin.conf" | grep -v '^#' | grep -v '^$'
    fi

    # Load iTerm2 themes
    fetch_iterm2_themes

    # Load custom themes if they exist
    if [ -f "$CACHE_DIR/custom-themes.conf" ]; then
        cat "$CACHE_DIR/custom-themes.conf" | grep -v '^#' | grep -v '^$'
    fi
}

# Show fzf picker
selected=$(load_themes | fzf \
    --height=50% \
    --border \
    --prompt="Select theme: " \
    --preview='
        line={}
        theme_name=$(echo "$line" | cut -d"|" -f1)
        colors=$(echo "$line" | cut -d"|" -f2)
        display_name=$(echo "$line" | cut -d"|" -f3)
        bg=$(echo "$colors" | grep -o "bg=#[0-9a-fA-F]*" | cut -d"#" -f2)
        fg=$(echo "$colors" | grep -o "fg=#[0-9a-fA-F]*" | cut -d"#" -f2)
        echo "Theme: $display_name"
        echo "Slug: $theme_name"
        echo ""
        echo "Background: #$bg"
        echo "Foreground: #$fg"
        echo ""
        echo "Preview:"
        printf "\033[48;2;$((16#${bg:0:2}));$((16#${bg:2:2}));$((16#${bg:4:2}))m"
        printf "\033[38;2;$((16#${fg:0:2}));$((16#${fg:2:2}));$((16#${fg:4:2}))m"
        echo "  This is sample text with the theme colors  "
        printf "\033[0m"
        echo ""
        echo ""
        echo "Controls:"
        echo "  Enter    - Apply theme to current pane"
        echo "  1-9      - Pin theme to palette slot"
        echo "  Esc      - Cancel"
    ' \
    --preview-window=right:60% \
    --bind='enter:accept' \
    --bind='1:execute(echo pin:1:{} > /tmp/tmux-theme-action)+abort' \
    --bind='2:execute(echo pin:2:{} > /tmp/tmux-theme-action)+abort' \
    --bind='3:execute(echo pin:3:{} > /tmp/tmux-theme-action)+abort' \
    --bind='4:execute(echo pin:4:{} > /tmp/tmux-theme-action)+abort' \
    --bind='5:execute(echo pin:5:{} > /tmp/tmux-theme-action)+abort' \
    --bind='6:execute(echo pin:6:{} > /tmp/tmux-theme-action)+abort' \
    --bind='7:execute(echo pin:7:{} > /tmp/tmux-theme-action)+abort' \
    --bind='8:execute(echo pin:8:{} > /tmp/tmux-theme-action)+abort' \
    --bind='9:execute(echo pin:9:{} > /tmp/tmux-theme-action)+abort' \
    --header='Enter=Apply | 1-9=Pin to palette | Esc=Cancel' \
    --delimiter='|' \
    --with-nth=3)

# Check for pin action
if [ -f /tmp/tmux-theme-action ]; then
    action=$(cat /tmp/tmux-theme-action)
    rm /tmp/tmux-theme-action

    slot=$(echo "$action" | cut -d: -f2)
    theme_line=$(echo "$action" | cut -d: -f3-)
    theme_name=$(echo "$theme_line" | cut -d'|' -f1)

    # Pin the theme to palette
    "$CURRENT_DIR/pin-theme.sh" "$theme_name" "$slot"
    tmux display-message "Theme '$theme_name' pinned to palette slot $slot"
    exit 0
fi

# If Enter was pressed, apply the theme
if [ -n "$selected" ]; then
    theme_name=$(echo "$selected" | cut -d'|' -f1)
    "$CURRENT_DIR/apply-theme.sh" "$theme_name"
fi
