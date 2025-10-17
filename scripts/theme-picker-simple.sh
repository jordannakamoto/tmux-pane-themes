#!/usr/bin/env bash

# Simple theme picker without fzf
CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
THEMES_DIR="$CURRENT_DIR/../themes"
CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/tmux-pane-themes"

# Save terminal state
OLD_STTY=$(stty -g)

# Ensure clean exit and restore terminal
cleanup() {
    stty "$OLD_STTY"
    tput cnorm
    clear
}
trap cleanup EXIT INT TERM

# Configure terminal for raw input
stty -echo -icanon min 1 time 0

# Hide cursor
tput civis

mkdir -p "$CACHE_DIR"

# Load themes into arrays for fast access
THEMES=()
THEME_NAMES=()
THEME_COLORS=()
THEME_DISPLAY=()

while read -r line; do
    IFS='|' read -r name colors display <<< "$line"
    THEMES+=("$line")
    THEME_NAMES+=("$name")
    THEME_COLORS+=("$colors")
    THEME_DISPLAY+=("$display")
done < <(
    (
        [ -f "$THEMES_DIR/builtin.conf" ] && grep -v '^#' "$THEMES_DIR/builtin.conf" | grep -v '^$'
        [ -f "$THEMES_DIR/iterm2.conf" ] && grep -v '^#' "$THEMES_DIR/iterm2.conf" | grep -v '^$'
        [ -f "$CACHE_DIR/custom-themes.conf" ] && grep -v '^#' "$CACHE_DIR/custom-themes.conf" | grep -v '^$'
    ) | sort -t'|' -k3
)

SELECTED=0
TOTAL=${#THEMES[@]}

# Function to draw palette
draw_palette() {
    local PALETTE_FILE="$CACHE_DIR/palette.conf"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "                                   PALETTE"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""

    if [ -f "$PALETTE_FILE" ] && [ -s "$PALETTE_FILE" ]; then
        while read -r line; do
            [ -z "$line" ] && continue
            IFS='|' read -r slot theme_name display_name <<< "$line"
            [ -z "$slot" ] && continue

            # Load colors
            colors=""
            [ -f "$THEMES_DIR/builtin.conf" ] && colors=$(grep "^$theme_name|" "$THEMES_DIR/builtin.conf" | cut -d"|" -f2)
            [ -z "$colors" ] && [ -f "$THEMES_DIR/iterm2.conf" ] && colors=$(grep "^$theme_name|" "$THEMES_DIR/iterm2.conf" | cut -d"|" -f2)

            if [ -n "$colors" ]; then
                bg=$(echo "$colors" | grep -o "bg=#[0-9a-fA-F]*" | cut -d"#" -f2)
                fg=$(echo "$colors" | grep -o "fg=#[0-9a-fA-F]*" | cut -d"#" -f2)

                printf "  [$slot]  "
                printf "\033[48;2;$((16#${bg:0:2}));$((16#${bg:2:2}));$((16#${bg:4:2}))m"
                printf "\033[38;2;$((16#${fg:0:2}));$((16#${fg:2:2}));$((16#${fg:4:2}))m"
                printf "  %-30s  " "$display_name"
                printf "\033[0m\n"
            fi
        done < <(sort -n "$PALETTE_FILE")
    else
        echo "  (empty - press 1-9 to pin themes)"
    fi

    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
}

# Function to draw only the theme list
draw_list() {
    # Calculate scroll position to keep selected item visible
    local visible_items=$((LIST_HEIGHT - 2))
    local start=0

    if [ $SELECTED -ge $visible_items ]; then
        start=$((SELECTED - visible_items + 1))
    fi

    local end=$((start + visible_items))
    [ $end -gt $TOTAL ] && end=$TOTAL

    # Build entire output in one string to minimize flashing
    local output=""
    local row=2  # Start at row 2 (after border)

    for ((i=start; i<end; i++)); do
        output+="\033[${row};1H"  # Move cursor (row;col)
        if [ $i -eq $SELECTED ]; then
            output+="│\033[7m $(printf "%-${LIST_WIDTH}s" "${THEME_DISPLAY[$i]:0:$LIST_WIDTH}")\033[0m│"
        else
            output+="│ $(printf "%-${LIST_WIDTH}s" "${THEME_DISPLAY[$i]:0:$LIST_WIDTH}")│"
        fi
        ((row++))
    done

    # Clear any remaining lines if we have fewer items than visible space
    local max_row=$((LIST_HEIGHT))
    while [ $row -lt $max_row ]; do
        output+="\033[${row};1H│$(printf "%${LIST_WIDTH}s" "")│"
        ((row++))
    done

    # Single write to minimize tearing
    printf "%b" "$output"
}

# Function to draw only the preview
draw_preview() {
    local theme_name="${THEME_NAMES[$SELECTED]}"
    local colors="${THEME_COLORS[$SELECTED]}"
    local display_name="${THEME_DISPLAY[$SELECTED]}"

    # Extract bg and fg quickly using parameter expansion
    local bg_with_prefix="${colors#*bg=#}"
    local bg="${bg_with_prefix%%,*}"
    local fg_with_prefix="${colors#*fg=#}"
    local fg="${fg_with_prefix%%,*}"

    # Build output string with embedded cursor movements
    local col=$((LIST_WIDTH + 2))
    local output="\033[48;2;$((16#${bg:0:2}));$((16#${bg:2:2}));$((16#${bg:4:2}))m"
    output+="\033[38;2;$((16#${fg:0:2}));$((16#${fg:2:2}));$((16#${fg:4:2}))m"

    # Fill preview area with colored background
    local blank_line=$(printf "%${PREVIEW_WIDTH}s" "")
    for ((i=0; i<LIST_HEIGHT+1; i++)); do
        output+="\033[$((i+1));${col}H${blank_line}"
    done

    # Add text content
    output+="\033[3;$((col+2))HTheme: $display_name"
    output+="\033[4;$((col+2))HSlug: $theme_name"
    output+="\033[6;$((col+2))HBackground: #$bg"
    output+="\033[7;$((col+2))HForeground: #$fg"
    output+="\033[10;$((col+2))HPreview text with theme colors"
    output+="\033[11;$((col+2))HLorem ipsum dolor sit amet"
    output+="\033[12;$((col+2))Hconst example = \"code sample\""
    output+="\033[13;$((col+2))Hfunction test() { return true; }"
    output+="\033[0m"

    printf "%b" "$output"
}

# Function to draw full UI (initial draw only)
draw_ui() {
    clear

    # Get terminal size
    ROWS=$(tput lines)
    COLS=$(tput cols)

    # Calculate layout
    LIST_WIDTH=30
    PREVIEW_WIDTH=$((COLS - LIST_WIDTH - 2))
    PALETTE_HEIGHT=12
    LIST_HEIGHT=$((ROWS - PALETTE_HEIGHT - 2))

    # Draw theme list border
    tput cup 0 0
    echo "┌─ THEMES ──────────────────┐"

    tput cup $((LIST_HEIGHT)) 0
    printf "└%${LIST_WIDTH}s┘" | tr ' ' '─'

    # Draw list and preview
    draw_list
    draw_preview

    # Draw palette at bottom
    tput cup $((LIST_HEIGHT + 2)) 0
    draw_palette

    # Draw controls
    tput cup $((ROWS - 1)) 0
    echo "↑/↓/j/k: Navigate | Enter: Apply | 1-9: Pin | Esc/q: Exit"
}

# Initial draw
draw_ui

# Main loop
NEEDS_FULL_REDRAW=0

while true; do
    # Read one character
    IFS= read -rsn1 char

    PREV_SELECTED=$SELECTED

    # Handle escape sequences
    if [[ $char == $'\x1b' ]]; then
        IFS= read -rsn1 next
        if [[ $next == '[' ]]; then
            IFS= read -rsn1 arrow
            if [[ $arrow == 'A' ]]; then
                # Up arrow
                ((SELECTED--))
                [ $SELECTED -lt 0 ] && SELECTED=$((TOTAL - 1))
            elif [[ $arrow == 'B' ]]; then
                # Down arrow
                ((SELECTED++))
                [ $SELECTED -ge $TOTAL ] && SELECTED=0
            fi
        else
            # Just Esc
            exit 0
        fi
    elif [[ $char == 'k' ]]; then
        # Up
        ((SELECTED--))
        [ $SELECTED -lt 0 ] && SELECTED=$((TOTAL - 1))
    elif [[ $char == 'j' ]]; then
        # Down
        ((SELECTED++))
        [ $SELECTED -ge $TOTAL ] && SELECTED=0
    elif [[ $char == 'q' ]]; then
        # Quit
        exit 0
    elif [[ $char == $'\n' || $char == $'\r' || $char == '' ]]; then
        # Enter
        theme_name="${THEME_NAMES[$SELECTED]}"
        FROM_PICKER=1 "$CURRENT_DIR/apply-theme.sh" "$theme_name"
        exit 0
    elif [[ $char =~ ^[1-9]$ ]]; then
        # Pin to palette - pass just the theme name
        theme_name="${THEME_NAMES[$SELECTED]}"
        "$CURRENT_DIR/pin-theme.sh" "$theme_name" "$char"
        tput cup $((LIST_HEIGHT + 2)) 0
        draw_palette
    fi

    # Only redraw changed regions when selection changes
    if [ $PREV_SELECTED -ne $SELECTED ]; then
        draw_list
        draw_preview
    fi
done
