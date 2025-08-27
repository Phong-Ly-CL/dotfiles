#!/bin/bash

# Dotfiles Uninstall Script
# Removes symlinks and restores from backup if available

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

log() { echo -e "${GREEN}[$(date +'%H:%M:%S')] $1${NC}"; }
warn() { echo -e "${YELLOW}[WARNING] $1${NC}"; }
error() { echo -e "${RED}[ERROR] $1${NC}"; exit 1; }
info() { echo -e "${BLUE}[INFO] $1${NC}"; }

# Find latest backup
find_latest_backup() {
    local backup_dir
    backup_dir=$(find "$HOME" -maxdepth 1 -name ".dotfiles-backup-*" -type d 2>/dev/null | sort -r | head -n1)
    echo "$backup_dir"
}

# Remove symlinks
remove_symlinks() {
    local configs=(".zshrc" ".gitconfig" ".p10k.zsh" ".vimrc" ".tmux.conf")
    
    log "Removing dotfiles symlinks..."
    
    for config in "${configs[@]}"; do
        local target_path="$HOME/$config"
        if [ -L "$target_path" ]; then
            rm "$target_path"
            info "Removed symlink: $config"
        elif [ -f "$target_path" ]; then
            warn "$config exists but is not a symlink - skipping"
        fi
    done
    
    # Remove neovim symlink
    if [ -L "$HOME/.config/nvim/init.vim" ]; then
        rm "$HOME/.config/nvim/init.vim"
        info "Removed neovim config symlink"
    fi
}

# Restore from backup
restore_backup() {
    local backup_dir
    backup_dir=$(find_latest_backup)
    
    if [ -z "$backup_dir" ]; then
        info "No backup found to restore"
        return
    fi
    
    log "Restoring from backup: $backup_dir"
    
    for file in "$backup_dir"/*; do
        if [ -f "$file" ]; then
            local filename
            filename=$(basename "$file")
            cp "$file" "$HOME/.$filename"
            info "Restored: .$filename"
        fi
    done
}

# Main uninstall function
main() {
    log "Starting dotfiles uninstall..."
    
    remove_symlinks
    restore_backup
    
    log "Uninstall completed!"
    info ""
    info "Your dotfiles symlinks have been removed."
    info "Original files have been restored from backup if available."
    info ""
    info "To completely remove dotfiles directory:"
    info "  rm -rf ~/.dotfiles"
}

main "$@"