#!/usr/bin/env bash

# Wrapper to setup panes for theme picker
CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/tmux-pane-themes"

# Get the current pane ID (this is the popup pane)
POPUP_PANE=$(tmux display-message -p '#{pane_id}')

# Split THIS pane to create palette pane below (30% height)
PALETTE_PANE=$(tmux split-window -v -p 30 -t "$POPUP_PANE" -P -F "#{pane_id}" "$CURRENT_DIR/show-palette-pane.sh")

# Select the top pane (the one we're in now)
tmux select-pane -t "$POPUP_PANE"

# Cleanup function
cleanup() {
    tmux kill-pane -t "$PALETTE_PANE" 2>/dev/null || true
}

trap cleanup EXIT INT TERM

# Run theme picker in this pane
"$CURRENT_DIR/theme-picker.sh"
