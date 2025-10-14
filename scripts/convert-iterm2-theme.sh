#!/usr/bin/env bash

# Convert iTerm2 .itermcolors XML to tmux color format
# Usage: convert-iterm2-theme.sh <theme-file.itermcolors>

if [ -z "$1" ]; then
    echo "Usage: $0 <theme-file.itermcolors>"
    exit 1
fi

THEME_FILE="$1"

# Extract RGB values and convert to hex
extract_color() {
    local key="$1"
    local r g b

    # Extract the color dict for the specified key
    r=$(grep -A 10 "<key>$key</key>" "$THEME_FILE" | grep -A 1 "Red Component" | grep "<real>" | sed 's/.*<real>\(.*\)<\/real>.*/\1/')
    g=$(grep -A 10 "<key>$key</key>" "$THEME_FILE" | grep -A 1 "Green Component" | grep "<real>" | sed 's/.*<real>\(.*\)<\/real>.*/\1/')
    b=$(grep -A 10 "<key>$key</key>" "$THEME_FILE" | grep -A 1 "Blue Component" | grep "<real>" | sed 's/.*<real>\(.*\)<\/real>.*/\1/')

    # Convert 0-1 float to 0-255 int, then to hex
    if [ -n "$r" ] && [ -n "$g" ] && [ -n "$b" ]; then
        r_int=$(printf "%.0f" $(echo "$r * 255" | bc))
        g_int=$(printf "%.0f" $(echo "$g * 255" | bc))
        b_int=$(printf "%.0f" $(echo "$b * 255" | bc))

        printf "#%02x%02x%02x" $r_int $g_int $b_int
    fi
}

# Extract background and foreground colors
bg=$(extract_color "Background Color")
fg=$(extract_color "Foreground Color")

if [ -n "$bg" ] && [ -n "$fg" ]; then
    echo "bg=$bg,fg=$fg"
else
    echo "Error: Could not extract colors from theme file" >&2
    exit 1
fi
