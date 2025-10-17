#!/usr/bin/env bash

# Interactive theme picker with fzf
CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
THEMES_DIR="$CURRENT_DIR/../themes"
CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/tmux-pane-themes"

# Ensure clean exit on Esc
trap 'clear; exit 0' EXIT

# Check if fzf is available
if ! command -v fzf &> /dev/null; then
    tmux display-message "fzf is required for the theme picker. Install with: brew install fzf"
    exit 1
fi

mkdir -p "$CACHE_DIR"

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

# Create preview script that reads from cache for palette
cat > "$CACHE_DIR/show-preview.sh" << 'PREVIEW_SCRIPT'
#!/usr/bin/env bash
CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/tmux-pane-themes"
CURRENT_DIR="$1"
THEMES_DIR="$CURRENT_DIR/../themes"

line="$2"
theme_name=$(echo "$line" | cut -d"|" -f1)
colors=$(echo "$line" | cut -d"|" -f2)
display_name=$(echo "$line" | cut -d"|" -f3)

bg=$(echo "$colors" | grep -o "bg=#[0-9a-fA-F]*" | cut -d"#" -f2)
fg=$(echo "$colors" | grep -o "fg=#[0-9a-fA-F]*" | cut -d"#" -f2)

# Apply colors to entire preview background
printf "\033[48;2;$((16#${bg:0:2}));$((16#${bg:2:2}));$((16#${bg:4:2}))m"
printf "\033[38;2;$((16#${fg:0:2}));$((16#${fg:2:2}));$((16#${fg:4:2}))m"
clear

echo ""
echo "  Theme: $display_name"
echo "  Slug: $theme_name"
echo ""
echo "  Background: #$bg"
echo "  Foreground: #$fg"
echo ""
echo ""
echo "  Preview text with theme colors"
echo "  Lorem ipsum dolor sit amet"
echo "  const example = \"code sample\""
echo "  function test() { return true; }"
echo ""
echo ""
echo ""
echo "  Controls:"
echo "    Enter  - Apply theme"
echo "    1-9    - Pin to palette"
echo "    Esc    - Cancel"

# Fill remaining space with colored background
for i in {1..50}; do echo ""; done
PREVIEW_SCRIPT

chmod +x "$CACHE_DIR/show-preview.sh"

# Show fzf picker
selected=$(load_themes | sort -t'|' -k3 | fzf \
    --height=100% \
    --border \
    --prompt="Select theme: " \
    --preview="$CACHE_DIR/show-preview.sh '$CURRENT_DIR' {}" \
    --preview='
        line={}
        theme_name=$(echo "$line" | cut -d"|" -f1)
        colors=$(echo "$line" | cut -d"|" -f2)
        display_name=$(echo "$line" | cut -d"|" -f3)

        bg=$(echo "$colors" | grep -o "bg=#[0-9a-fA-F]*" | cut -d"#" -f2)
        fg=$(echo "$colors" | grep -o "fg=#[0-9a-fA-F]*" | cut -d"#" -f2)

        # Apply colors to entire preview background
        printf "\033[48;2;$((16#${bg:0:2}));$((16#${bg:2:2}));$((16#${bg:4:2}))m"
        printf "\033[38;2;$((16#${fg:0:2}));$((16#${fg:2:2}));$((16#${fg:4:2}))m"
        clear

        echo ""
        echo "  Theme: $display_name"
        echo "  Slug: $theme_name"
        echo ""
        echo "  Background: #$bg"
        echo "  Foreground: #$fg"
        echo ""
        echo ""
        echo "  Preview text with theme colors"
        echo "  Lorem ipsum dolor sit amet"
        echo "  const example = \"code sample\""
        echo "  function test() { return true; }"
        echo ""
        echo ""
        echo ""
        echo "  Controls:"
        echo "    Enter  - Apply theme"
        echo "    1-9    - Pin to palette"
        echo "    Esc    - Cancel"

        # Fill remaining space with colored background
        for i in {1..50}; do echo ""; done
    ' \
    --preview-window='right:70%' \
    --bind='enter:accept' \
    --bind="1:execute-silent($CURRENT_DIR/pin-theme.sh {1} 1)+reload(load_themes | sort -t'|' -k3)" \
    --bind="2:execute-silent($CURRENT_DIR/pin-theme.sh {1} 2)+reload(load_themes | sort -t'|' -k3)" \
    --bind="3:execute-silent($CURRENT_DIR/pin-theme.sh {1} 3)+reload(load_themes | sort -t'|' -k3)" \
    --bind="4:execute-silent($CURRENT_DIR/pin-theme.sh {1} 4)+reload(load_themes | sort -t'|' -k3)" \
    --bind="5:execute-silent($CURRENT_DIR/pin-theme.sh {1} 5)+reload(load_themes | sort -t'|' -k3)" \
    --bind="6:execute-silent($CURRENT_DIR/pin-theme.sh {1} 6)+reload(load_themes | sort -t'|' -k3)" \
    --bind="7:execute-silent($CURRENT_DIR/pin-theme.sh {1} 7)+reload(load_themes | sort -t'|' -k3)" \
    --bind="8:execute-silent($CURRENT_DIR/pin-theme.sh {1} 8)+reload(load_themes | sort -t'|' -k3)" \
    --bind="9:execute-silent($CURRENT_DIR/pin-theme.sh {1} 9)+reload(load_themes | sort -t'|' -k3)" \
    --header='Enter=Apply | 1-9=Pin to palette | Esc=Cancel' \
    --delimiter='|' \
    --with-nth=3)

# If Enter was pressed, apply the theme
if [ -n "$selected" ]; then
    theme_name=$(echo "$selected" | cut -d'|' -f1)
    FROM_PICKER=1 "$CURRENT_DIR/apply-theme.sh" "$theme_name"
    clear
    exit 0
fi

# If Esc was pressed or nothing selected, just exit cleanly
clear
exit 0
