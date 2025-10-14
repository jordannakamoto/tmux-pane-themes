#!/usr/bin/env bash

# Fetch iTerm2 color schemes and convert to our format
CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
THEMES_DIR="$CURRENT_DIR/../themes"
CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/tmux-pane-themes"

mkdir -p "$CACHE_DIR"

ITERM2_URL="https://raw.githubusercontent.com/mbadolato/iTerm2-Color-Schemes/master/schemes"

echo "Fetching iTerm2 color scheme list..."

# We'll download the schemes on-demand rather than cloning the whole repo
# For now, we'll maintain a curated list of popular schemes
# Users can add more by URL if needed

# The converter will parse iTerm2 .itermcolors XML format
# and extract Background Color and Foreground Color
# converting from RGB to hex format for tmux
