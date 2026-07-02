#!/bin/bash

# Dotfiles Backup Script
# Copies current (non-symlinked) dotfiles into a timestamped backup directory

set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

log() { echo -e "${GREEN}[$(date +'%H:%M:%S')] $1${NC}"; }
info() { echo -e "${BLUE}[INFO] $1${NC}"; }

BACKUP_DIR="$HOME/.dotfiles-backup-$(date +%Y%m%d-%H%M%S)"
FILES=(
    ".zshrc"
    ".zshrc.local"
    ".gitconfig"
    ".p10k.zsh"
    ".vimrc"
    ".tmux.conf"
    ".config/nvim/init.vim"
    ".claude/settings.json"
    ".claude/statusline.sh"
)

log "Backing up dotfiles to $BACKUP_DIR..."
backed_up=false

for file in "${FILES[@]}"; do
    src="$HOME/$file"
    if [ -f "$src" ]; then
        mkdir -p "$BACKUP_DIR/$(dirname "$file")"
        # -L follows symlinks so we back up the actual content
        cp -L "$src" "$BACKUP_DIR/$file"
        info "✓ Backed up $file"
        backed_up=true
    fi
done

if [ "$backed_up" = true ]; then
    log "Backup complete: $BACKUP_DIR"
else
    rmdir "$BACKUP_DIR" 2>/dev/null || true
    info "Nothing to back up"
fi
