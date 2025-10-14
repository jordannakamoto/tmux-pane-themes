#!/usr/bin/env bash

# Tmux Pane Themes Plugin
# Entry point for TPM (Tmux Plugin Manager)

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Set default options
tmux set-option -g @pane-themes-cache-dir "$HOME/.cache/tmux_pane_themes" 2>/dev/null

# Restore saved themes on tmux start
tmux run-shell "$CURRENT_DIR/scripts/restore-themes.sh"

# Bind keys for theme selection
# Right-click menu integration will be handled in user's tmux.conf
# But we can provide a keybinding for the theme menu
tmux bind-key T run-shell "$CURRENT_DIR/scripts/show-theme-menu.sh"
