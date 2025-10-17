#!/usr/bin/env bash

# Show palette in a watch loop
CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/tmux-pane-themes"
PALETTE_FILE="$CACHE_DIR/palette.conf"
CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
THEMES_DIR="$CURRENT_DIR/../themes"

while true; do
    clear
    echo "═══════════════════════════════════════════════════════════════════════════════════"
    echo "                                   PALETTE"
    echo "═══════════════════════════════════════════════════════════════════════════════════"
    echo ""

    if [ -f "$PALETTE_FILE" ] && [ -s "$PALETTE_FILE" ]; then
        while IFS='|' read -r slot theme_name display_name; do
            [ -z "$slot" ] && continue

            # Load theme colors
            colors=""
            if [ -f "$THEMES_DIR/builtin.conf" ]; then
                colors=$(grep "^$theme_name|" "$THEMES_DIR/builtin.conf" | cut -d'|' -f2)
            fi
            if [ -z "$colors" ] && [ -f "$THEMES_DIR/iterm2.conf" ]; then
                colors=$(grep "^$theme_name|" "$THEMES_DIR/iterm2.conf" | cut -d'|' -f2)
            fi

            if [ -n "$colors" ]; then
                bg=$(echo "$colors" | grep -o "bg=#[0-9a-fA-F]*" | cut -d"#" -f2)
                fg=$(echo "$colors" | grep -o "fg=#[0-9a-fA-F]*" | cut -d"#" -f2)

                # Show palette entry with colored preview
                printf "  [$slot]  "
                printf "\033[48;2;$((16#${bg:0:2}));$((16#${bg:2:2}));$((16#${bg:4:2}))m"
                printf "\033[38;2;$((16#${fg:0:2}));$((16#${fg:2:2}));$((16#${fg:4:2}))m"
                printf "  %-30s  " "$display_name"
                printf "\033[0m"
                printf "  #%s / #%s\n" "$bg" "$fg"
            fi
        done < <(sort -n "$PALETTE_FILE")
    else
        echo "  (empty - press 1-9 in the theme picker to pin themes)"
    fi

    echo ""
    echo "═══════════════════════════════════════════════════════════════════════════════════"

    sleep 0.5
done
