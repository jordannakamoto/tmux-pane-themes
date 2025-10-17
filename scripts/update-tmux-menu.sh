#!/usr/bin/env bash

# Update tmux.conf right-click menu with pinned themes
CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/tmux-pane-themes"
PALETTE_FILE="$CACHE_DIR/palette.conf"
TMUX_CONF="${TMUX_CONF:-$HOME/.tmux.conf}"

# Detect plugin installation directory (prefer TPM location)
if [ -d "$HOME/.tmux/plugins/tmux-pane-themes" ]; then
    PLUGIN_DIR="$HOME/.tmux/plugins/tmux-pane-themes"
else
    # Fallback to current directory (dev mode)
    PLUGIN_DIR="$( cd "$CURRENT_DIR/.." && pwd )"
fi

# Ensure palette file exists
mkdir -p "$CACHE_DIR"
touch "$PALETTE_FILE"

# Build the right-click menu binding
generate_menu_binding() {
    cat <<EOF
bind-key -n MouseDown3Pane if-shell -F -t = "#{||:#{mouse_any_flag},#{pane_in_mode}}" "select-pane -t=; send-keys -M" "display-menu -T \\\"#[align=centre]#{pane_index} (#{pane_id})\\\" -t = -x M -y M 'Horizontal Split' h 'split-window -h' 'Vertical Split' v 'split-window -v' '' 'Swap Up' u 'swap-pane -U' 'Swap Down' d 'swap-pane -D' '' 'Themes...' t 'run-shell \\\"$PLUGIN_DIR/scripts/show-themes-menu.sh\\\"' '' Kill X kill-pane Respawn R 'respawn-pane -k' '#{?pane_marked,Unmark,Mark}' m 'select-pane -m' '#{?window_zoomed_flag,Unzoom,Zoom}' z 'resize-pane -Z'"
EOF
}

# Check if tmux.conf has the managed section
if ! grep -q "# BEGIN TMUX-PANE-THEMES MANAGED SECTION" "$TMUX_CONF" 2>/dev/null; then
    # Add managed section marker
    cat >> "$TMUX_CONF" <<EOF

# BEGIN TMUX-PANE-THEMES MANAGED SECTION
# This section is automatically updated by tmux-pane-themes plugin
# Do not manually edit between BEGIN and END markers
$(generate_menu_binding)
# END TMUX-PANE-THEMES MANAGED SECTION
EOF
else
    # Update existing managed section
    new_binding=$(generate_menu_binding)

    # Use awk to replace content between markers
    awk -v new="$new_binding" '
    /# BEGIN TMUX-PANE-THEMES MANAGED SECTION/ {
        print
        print "# This section is automatically updated by tmux-pane-themes plugin"
        print "# Do not manually edit between BEGIN and END markers"
        print new
        skip=1
        next
    }
    /# END TMUX-PANE-THEMES MANAGED SECTION/ {
        skip=0
    }
    !skip
    ' "$TMUX_CONF" > "$TMUX_CONF.tmp"

    mv "$TMUX_CONF.tmp" "$TMUX_CONF"
fi

# Reload tmux config
if [ -n "$TMUX" ]; then
    tmux source-file "$TMUX_CONF"
fi
