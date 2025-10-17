#!/usr/bin/env bash

# Tmux Pane Themes Plugin
# Entry point for TPM (Tmux Plugin Manager)

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Set default options
tmux set-option -g @pane-themes-cache-dir "$HOME/.cache/tmux_pane_themes" 2>/dev/null

# Restore saved themes on tmux start
tmux run-shell "$CURRENT_DIR/scripts/restore-themes.sh"

# Bind key for theme picker (prefix + T)
tmux bind-key T run-shell "tmux popup -E -w 90% -h 90% 'bash $CURRENT_DIR/scripts/theme-picker-simple.sh'"
