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

If you don't have TPM:
```bash
git clone https://github.com/tmux-plugin-manager/tpm ~/.tmux/plugins/tpm
```

Add to your `~/.tmux.conf`:
```tmux
set -g @plugin 'jordannakamoto/tmux-pane-themes'

# Initialize TPM (keep at bottom of tmux.conf)
run '~/.tmux/plugins/tpm/tpm'
```

Reload config and install: `tmux source ~/.tmux.conf` then press `prefix + I`

### Manual Installation

```bash
git clone https://github.com/jordannakamoto/tmux-pane-themes ~/.tmux/plugins/tmux-pane-themes
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

**Quick start:**
1. Press `prefix + T` to browse themes
2. Press `Enter` to apply, or `1-9` to pin to your palette
3. Right-click any pane → **Themes** → select your pinned themes

**Includes 12 starter themes:**
Tokyo Night • Gruvbox Dark/Light • Catppuccin • Nord • Dracula • Ocean • Forest • Sunset • Coffee • Cyberpunk • Pastel

## Advanced

**Add custom themes** to `~/.cache/tmux-pane-themes/custom-themes.conf`:
```
my-theme|bg=#1a1b26,fg=#c0caf5|My Custom Theme
```

**Import iTerm2 themes:**
```bash
./scripts/convert-iterm2-theme.sh theme.itermcolors
```

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
