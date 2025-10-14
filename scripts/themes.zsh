# Tmux pane theme loader for zsh
# Source this file in your .zshrc to apply per-pane themes to your shell

CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/tmux-pane-themes"

# Function to get current pane's theme
get_pane_theme() {
    local theme_file="$CACHE_DIR/pane-themes"
    if [ -f "$theme_file" ] && [ -n "$TMUX_PANE" ]; then
        grep "^$TMUX_PANE:" "$theme_file" 2>/dev/null | cut -d: -f2
    fi
}

# Load the theme for this pane
TMUX_PANE_THEME="${TMUX_PANE_THEME:-$(get_pane_theme)}"

# Theme definitions for shell integration
case "$TMUX_PANE_THEME" in
    tokyo-night)
        export FZF_DEFAULT_OPTS="--color=bg+:#1a1b26,bg:#1a1b26,spinner:#bb9af7,hl:#7aa2f7 --color=fg:#c0caf5,header:#7aa2f7,info:#7aa2f7,pointer:#bb9af7 --color=marker:#bb9af7,fg+:#c0caf5,prompt:#7aa2f7,hl+:#7aa2f7"
        export BAT_THEME="TwoDark"
        PROMPT='%F{#7aa2f7}%~%f %# '
        ;;
    gruvbox-dark)
        export FZF_DEFAULT_OPTS="--color=bg+:#3c3836,bg:#282828,spinner:#fb4934,hl:#83a598 --color=fg:#ebdbb2,header:#83a598,info:#fabd2f,pointer:#fb4934 --color=marker:#fb4934,fg+:#ebdbb2,prompt:#83a598,hl+:#83a598"
        export BAT_THEME="gruvbox-dark"
        PROMPT='%F{#fabd2f}%~%f %# '
        ;;
    gruvbox-light)
        export FZF_DEFAULT_OPTS="--color=bg+:#d5c4a1,bg:#fbf1c7,spinner:#9d0006,hl:#076678 --color=fg:#3c3836,header:#076678,info:#b57614,pointer:#9d0006 --color=marker:#9d0006,fg+:#3c3836,prompt:#076678,hl+:#076678"
        export BAT_THEME="gruvbox-light"
        PROMPT='%F{#af3a03}%~%f %# '
        ;;
    catppuccin)
        export FZF_DEFAULT_OPTS="--color=bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#89b4fa --color=fg:#cdd6f4,header:#89b4fa,info:#cba6f7,pointer:#f5e0dc --color=marker:#f5e0dc,fg+:#cdd6f4,prompt:#cba6f7,hl+:#89b4fa"
        export BAT_THEME="Catppuccin-mocha"
        PROMPT='%F{#89b4fa}%~%f %# '
        ;;
    nord)
        export FZF_DEFAULT_OPTS="--color=bg+:#3b4252,bg:#2e3440,spinner:#88c0d0,hl:#81a1c1 --color=fg:#d8dee9,header:#81a1c1,info:#eacb8a,pointer:#88c0d0 --color=marker:#88c0d0,fg+:#d8dee9,prompt:#81a1c1,hl+:#81a1c1"
        export BAT_THEME="Nord"
        PROMPT='%F{#88c0d0}%~%f %# '
        ;;
    dracula)
        export FZF_DEFAULT_OPTS="--color=bg+:#44475a,bg:#282a36,spinner:#ff79c6,hl:#bd93f9 --color=fg:#f8f8f2,header:#bd93f9,info:#ffb86c,pointer:#ff79c6 --color=marker:#ff79c6,fg+:#f8f8f2,prompt:#bd93f9,hl+:#bd93f9"
        export BAT_THEME="Dracula"
        PROMPT='%F{#bd93f9}%~%f %# '
        ;;
    ocean)
        export FZF_DEFAULT_OPTS="--color=bg+:#1a2332,bg:#0d1620,spinner:#4dd0e1,hl:#42a5f5 --color=fg:#b0d4e8,header:#42a5f5,info:#29b6f6,pointer:#4dd0e1 --color=marker:#4dd0e1,fg+:#e0f7fa,prompt:#42a5f5,hl+:#42a5f5"
        export BAT_THEME="TwoDark"
        PROMPT='%F{#4dd0e1}%~%f %# '
        ;;
    forest)
        export FZF_DEFAULT_OPTS="--color=bg+:#1e2a1e,bg:#121a12,spinner:#81c784,hl:#66bb6a --color=fg:#c8e6c9,header:#66bb6a,info:#aed581,pointer:#81c784 --color=marker:#81c784,fg+:#e8f5e9,prompt:#66bb6a,hl+:#66bb6a"
        export BAT_THEME="TwoDark"
        PROMPT='%F{#81c784}%~%f %# '
        ;;
    sunset)
        export FZF_DEFAULT_OPTS="--color=bg+:#2a1a2e,bg:#1a0f1e,spinner:#ff6b9d,hl:#ffa07a --color=fg:#ffd7ba,header:#ffa07a,info:#ff8c94,pointer:#ff6b9d --color=marker:#ff6b9d,fg+:#ffe4d6,prompt:#ffa07a,hl+:#ffa07a"
        export BAT_THEME="TwoDark"
        PROMPT='%F{#ff8c94}%~%f %# '
        ;;
    coffee)
        export FZF_DEFAULT_OPTS="--color=bg+:#2a211c,bg:#1a1410,spinner:#d4a574,hl:#c9a56b --color=fg:#e8d5b7,header:#c9a56b,info:#d4a574,pointer:#d4a574 --color=marker:#d4a574,fg+:#f5ead6,prompt:#c9a56b,hl+:#c9a56b"
        export BAT_THEME="TwoDark"
        PROMPT='%F{#d4a574}%~%f %# '
        ;;
    cyberpunk)
        export FZF_DEFAULT_OPTS="--color=bg+:#1a1a2e,bg:#0f0f1e,spinner:#ff00ff,hl:#00ffff --color=fg:#e0e0ff,header:#00ffff,info:#ffff00,pointer:#ff00ff --color=marker:#ff00ff,fg+:#ffffff,prompt:#00ffff,hl+:#00ffff"
        export BAT_THEME="TwoDark"
        PROMPT='%F{#00ffff}%~%f %# '
        ;;
    pastel)
        export FZF_DEFAULT_OPTS="--color=bg+:#25233a,bg:#1a1826,spinner:#f5c2e7,hl:#cba6f7 --color=fg:#e0def4,header:#cba6f7,info:#f5c2e7,pointer:#f5c2e7 --color=marker:#f5c2e7,fg+:#e0def4,prompt:#cba6f7,hl+:#cba6f7"
        export BAT_THEME="TwoDark"
        PROMPT='%F{#f5c2e7}%~%f %# '
        ;;
esac
