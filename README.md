# Modern Dotfiles Setup

A modern, organized dotfiles repository with symlink-based installation and environment-specific configurations.

## ⚡ Quick Installation

```bash
# Clone the repository
git clone https://github.com/Phong-Ly-CL/dotfiles.git ~/.dotfiles
cd ~/.dotfiles

# Install with symlinks
./install.sh

# Or use make
make install
```

## 📁 Directory Structure

```
~/.dotfiles/
├── configs/
│   ├── claude/
│   │   ├── settings.json    # Claude Code settings
│   │   └── statusline.sh    # Claude Code statusline (usage bars + reset countdown)
│   ├── environments/     # Environment-specific configs
│   ├── git/
│   │   └── gitconfig    # Main git config
│   ├── ssh/
│   │   └── config.template  # SSH configuration template
│   ├── tmux/
│   │   └── tmux.conf    # Tmux configuration
│   ├── vim/
│   │   ├── init.vim     # Neovim configuration
│   │   └── vimrc        # Vim configuration
│   └── zsh/
│       ├── p10k.zsh     # Powerlevel10k theme
│       └── zshrc        # Main zsh configuration
├── scripts/             # Installation and utility scripts
├── templates/           # Configuration templates
├── install.sh          # Main installation script
├── Makefile            # Make targets for management
└── README.md           # This file
```

## 🛠️ What's Included

### Shell Configuration
- **ZSH** with oh-my-zsh
- **Powerlevel10k** theme
- **Auto-suggestions** and **syntax highlighting**
- **Environment-specific** configurations (Codespaces, WSL, macOS)

### Development Tools
- **Vim/Neovim** configuration with sensible defaults
- **Tmux** configuration with vim-like navigation
- **Git** configuration with useful aliases
- **SSH** configuration template
- **Claude Code** settings and statusline (model, cost, context and rate-limit usage bars with reset countdowns)

### Modern CLI Tools
- `bat` for better `cat`
- `lsd` for better `ls`
- `htop` for better `top`

## 🔧 Management Commands

```bash
make help        # Show available commands
make install     # Install dotfiles
make uninstall   # Remove symlinks and restore backups
make backup      # Create backup of current dotfiles
make test        # Test configuration files
make update      # Update from git and reinstall
make clean       # Clean temporary files
```

## 🌍 Environment Detection

Environment detection lives in `~/.zshrc.local` (created from `templates/zshrc.local.template` on install). It detects your environment and loads the matching config from `configs/environments/`:

- **GitHub Codespaces**: Workspace aliases and development settings
- **WSL**: Windows integration and path settings  
- **macOS**: Homebrew and macOS-specific tools
- **Linux**: Generic Linux configuration

## ⚙️ Customization

### Personal Configuration
1. Copy the template: `cp templates/zshrc.local.template ~/.zshrc.local`
2. Customize aliases and environment variables
3. The template includes auto-detection for your environment

### SSH Configuration
1. Copy the template: `cp configs/ssh/config.template ~/.ssh/config`
2. Add your servers and keys
3. The template includes security best practices

## 🔄 Symlink-Based Installation

Unlike traditional dotfiles that copy files, this setup uses symlinks:

- ✅ **Easy updates**: Changes sync automatically
- ✅ **Version control**: All changes are tracked
- ✅ **Backup safety**: Original files are backed up
- ✅ **Clean uninstall**: Remove symlinks, restore originals

## 📦 Installed Packages

The installation script automatically installs:
- `zsh` - Modern shell
- `tmux` - Terminal multiplexer  
- `vim` - Text editor
- `bat` - Better cat with syntax highlighting
- `lsd` - Better ls with colors and icons
- `htop` - Better top with colors

## 🚨 Safety Features

- **Automatic backup** of existing dotfiles
- **Non-destructive** installation (preserves your current setup)
- **Easy rollback** with uninstall script
- **Gitignore** for sensitive files

## 🎯 Git Aliases

Included git aliases for productivity:
- `git st` - status
- `git co` - checkout
- `git codev` - checkout develop
- `git cmm` - commit with message
- `git cma` - commit amend
- `git lg` - beautiful log graph
- `git stpu` - stash push
- `git stpo` - stash pop

## 🔧 Troubleshooting

### ZSH not loading properly
```bash
# Test the configuration
zsh -n ~/.zshrc

# Source manually
source ~/.zshrc
```

### ZSH plugins not found
```bash
# For codespaces - force reinstall plugins
rm -rf ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions
rm -rf ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-autosuggestions ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting

# Verify plugin files exist
ls -la ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions/*.plugin.zsh
ls -la ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting/*.plugin.zsh

# Install Powerlevel10k theme if needed
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/.oh-my-zsh/custom/themes/powerlevel10k

# Then source your zshrc
source ~/.zshrc
```

### Tmux configuration issues
```bash
# Test tmux config
tmux -f ~/.tmux.conf list-keys

# Reload tmux config
tmux source-file ~/.tmux.conf
```

### Restore from backup
```bash
# Find your backup
ls -la ~ | grep dotfiles-backup

# Run uninstall to restore
./scripts/uninstall.sh
```

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch
3. Make your changes
4. Test with `make test`
5. Submit a pull request

## 📄 License

This project is open source. Feel free to use and modify as needed.

---

**Quick Start Summary:**
```bash
git clone https://github.com/Phong-Ly-CL/dotfiles.git ~/.dotfiles && ~/.dotfiles/install.sh
```