# tmux-pane-themes

Per-pane theme management for tmux. Visually differentiate panes with different color themes.

## Features

- **Per-pane themes**: Each tmux pane can have its own color theme
- **Interactive picker**: Browse and preview themes with fzf
- **Custom palette**: Pin your favorite themes to the right-click menu
- **Shell integration**: Themes apply to shell prompt, fzf, bat, and more
- **Persistent themes**: Themes are restored when tmux restarts
- **12 built-in themes**: Popular color schemes included
- **Extensible**: Add custom themes or import from iTerm2 color schemes

## Installation

### Prerequisites

- tmux 3.0+
- fzf (for the interactive picker)
- zsh (for shell integration, optional)

### Using TPM (Tmux Plugin Manager)

Add to your `~/.tmux.conf`:

```tmux
set -g @plugin 'yourusername/tmux-pane-themes'
```

Then press `prefix + I` to install.

### Manual Installation

```bash
git clone https://github.com/yourusername/tmux-pane-themes ~/.tmux/plugins/tmux-pane-themes
```

Add to your `~/.tmux.conf`:

```tmux
run-shell ~/.tmux/plugins/tmux-pane-themes/pane-themes.tmux
```

### Shell Integration (Optional)

For zsh, add to your `~/.zshrc`:

```bash
# Source after tmux setup
[ -f ~/.tmux/plugins/tmux-pane-themes/scripts/themes.zsh ] && \
    source ~/.tmux/plugins/tmux-pane-themes/scripts/themes.zsh
```

This enables theme-aware prompt, fzf colors, and bat theme.

## Usage

### Interactive Theme Picker

Press `prefix + T` to open the interactive theme picker.

- **Enter**: Apply theme to current pane
- **1-9**: Pin theme to palette slot (adds to right-click menu)
- **Esc**: Cancel

### Right-Click Menu

Right-click on any pane → **Themes...** → Select a pinned theme

The right-click menu dynamically updates when you pin themes from the picker.

### Built-in Themes

- Tokyo Night
- Gruvbox Dark
- Gruvbox Light
- Catppuccin
- Nord
- Dracula
- Ocean
- Forest
- Sunset
- Coffee
- Cyberpunk
- Pastel

## Customization

### Adding Custom Themes

Create `~/.cache/tmux-pane-themes/custom-themes.conf`:

```
my-theme|bg=#1a1b26,fg=#c0caf5|My Custom Theme
another-theme|bg=#282828,fg=#ebdbb2|Another Theme
```

Format: `theme-slug|bg=#hexcolor,fg=#hexcolor|Display Name`

### Importing iTerm2 Themes

```bash
# Download an iTerm2 .itermcolors file
curl -o ~/Downloads/Solarized.itermcolors https://example.com/theme.itermcolors

# Convert to tmux format
~/.tmux/plugins/tmux-pane-themes/scripts/convert-iterm2-theme.sh ~/Downloads/Solarized.itermcolors

# Add to custom themes
echo "solarized|$(~/.tmux/plugins/tmux-pane-themes/scripts/convert-iterm2-theme.sh ~/Downloads/Solarized.itermcolors)|Solarized" \
    >> ~/.cache/tmux-pane-themes/custom-themes.conf
```

### Configuration Options

```tmux
# Change cache directory (default: ~/.cache/tmux_pane_themes)
set -g @pane-themes-cache-dir "~/.local/share/tmux-themes"
```

## How It Works

1. **Theme Application**: When you apply a theme, tmux's `select-pane -P` sets the pane's background and foreground colors
2. **Theme Storage**: The pane-theme mapping is stored in `~/.cache/tmux-pane-themes/pane-themes`
3. **Theme Restoration**: On tmux start, themes are automatically restored to existing panes
4. **Shell Integration**: When a theme is applied, the shell is restarted with `TMUX_PANE_THEME` set, which triggers the zsh integration
5. **Palette Management**: Pinned themes are stored in `palette.conf` and automatically update the tmux.conf right-click menu

## Troubleshooting

### Themes not showing colors

Ensure your terminal supports true color:

```tmux
set -g default-terminal "tmux-256color"
set -ga terminal-overrides ",*256col*:Tc"
```

### fzf picker not working

Install fzf:

```bash
brew install fzf  # macOS
# or
apt install fzf   # Ubuntu/Debian
```

### Shell theme not applying

Make sure you've sourced `themes.zsh` in your `.zshrc` and that the shell integration is loaded.

## License

MIT

## Contributing

Contributions welcome! Please open an issue or PR on GitHub.
