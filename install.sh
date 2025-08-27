#!/bin/bash

# Modern Dotfiles Installation Script
# Uses symlinks instead of copying for easier updates
# Author: Phong Ly

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Configuration
DOTFILES_DIR="$HOME/.dotfiles"
BACKUP_DIR="$HOME/.dotfiles-backup-$(date +%Y%m%d-%H%M%S)"

# Logging functions
log() { echo -e "${GREEN}[$(date +'%H:%M:%S')] $1${NC}"; }
warn() { echo -e "${YELLOW}[WARNING] $1${NC}"; }
error() { echo -e "${RED}[ERROR] $1${NC}"; exit 1; }
info() { echo -e "${BLUE}[INFO] $1${NC}"; }

# Check if command exists
command_exists() { command -v "$1" >/dev/null 2>&1; }

# Create backup of existing dotfiles
backup_existing() {
    local files=(".zshrc" ".gitconfig" ".p10k.zsh" ".vimrc" ".tmux.conf")
    local backed_up=false
    
    for file in "${files[@]}"; do
        if [ -f "$HOME/$file" ] && [ ! -L "$HOME/$file" ]; then
            if [ "$backed_up" = false ]; then
                log "Creating backup directory: $BACKUP_DIR"
                mkdir -p "$BACKUP_DIR"
                backed_up=true
            fi
            info "Backing up $file"
            cp "$HOME/$file" "$BACKUP_DIR/"
        fi
    done
    
    [ "$backed_up" = true ] && info "Existing dotfiles backed up to $BACKUP_DIR"
}

# Create symlinks
create_symlinks() {
    local configs=(
        "configs/zshrc:.zshrc"
        "configs/gitconfig:.gitconfig" 
        "configs/p10k.zsh:.p10k.zsh"
        "configs/vim/vimrc:.vimrc"
        "configs/tmux/tmux.conf:.tmux.conf"
    )
    
    log "Creating symlinks..."
    
    for config in "${configs[@]}"; do
        local source_file="${config%:*}"
        local target_file="${config#*:}"
        local source_path="$DOTFILES_DIR/$source_file"
        local target_path="$HOME/$target_file"
        
        if [ -f "$source_path" ]; then
            # Remove existing file/symlink
            [ -e "$target_path" ] && rm "$target_path"
            
            # Create symlink
            ln -sf "$source_path" "$target_path"
            info "Linked $source_file -> $target_file"
        else
            warn "Source file $source_path not found"
        fi
    done
}

# Setup directories
setup_directories() {
    log "Setting up directories..."
    
    # Create necessary directories
    mkdir -p "$HOME/.config/nvim"
    mkdir -p "$HOME/.ssh"
    
    # Neovim config symlink
    if [ -f "$DOTFILES_DIR/configs/vim/init.vim" ]; then
        ln -sf "$DOTFILES_DIR/configs/vim/init.vim" "$HOME/.config/nvim/init.vim"
        info "Linked neovim config"
    fi
    
    # SSH config template (don't overwrite existing)
    if [ ! -f "$HOME/.ssh/config" ] && [ -f "$DOTFILES_DIR/configs/ssh/config.template" ]; then
        info "SSH config template available at configs/ssh/config.template"
        info "Copy and customize it manually to ~/.ssh/config"
    fi
}

# Install packages
install_packages() {
    log "Installing required packages..."
    
    # Update package list
    if command_exists apt; then
        sudo apt update || warn "Failed to update package list"
        local packages=("bat" "lsd" "htop" "zsh" "tmux" "vim")
    elif command_exists yum; then
        local packages=("bat" "htop" "zsh" "tmux" "vim")
    elif command_exists brew; then
        local packages=("bat" "lsd" "htop" "zsh" "tmux" "vim")
    else
        warn "No supported package manager found"
        return
    fi
    
    for package in "${packages[@]}"; do
        if ! command_exists "$package"; then
            info "Installing $package..."
            if command_exists apt; then
                sudo apt install -y "$package" || warn "Failed to install $package"
            elif command_exists yum; then
                sudo yum install -y "$package" || warn "Failed to install $package"
            elif command_exists brew; then
                brew install "$package" || warn "Failed to install $package"
            fi
        else
            info "$package already installed"
        fi
    done
}

# Setup ZSH plugins
setup_zsh() {
    log "Setting up ZSH plugins..."
    
    # Install oh-my-zsh if not present
    if [ ! -d "$HOME/.oh-my-zsh" ]; then
        info "Installing oh-my-zsh..."
        sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended || warn "Failed to install oh-my-zsh"
    fi
    
    # Install plugins
    local plugins=(
        "zsh-autosuggestions:https://github.com/zsh-users/zsh-autosuggestions"
        "zsh-syntax-highlighting:https://github.com/zsh-users/zsh-syntax-highlighting"
    )
    
    for plugin in "${plugins[@]}"; do
        local plugin_name="${plugin%:*}"
        local plugin_repo="${plugin#*:}"
        local plugin_dir="$HOME/.oh-my-zsh/custom/plugins/$plugin_name"
        
        if [ ! -d "$plugin_dir" ]; then
            info "Installing $plugin_name..."
            git clone "$plugin_repo" "$plugin_dir" || warn "Failed to install $plugin_name"
        fi
    done
    
    # Install Powerlevel10k theme
    local p10k_dir="$HOME/.oh-my-zsh/custom/themes/powerlevel10k"
    if [ ! -d "$p10k_dir" ]; then
        info "Installing Powerlevel10k theme..."
        git clone https://github.com/romkatv/powerlevel10k.git "$p10k_dir" || warn "Failed to install Powerlevel10k"
    fi
}

# Setup templates
setup_templates() {
    log "Setting up configuration templates..."
    
    # Create local zshrc if it doesn't exist
    if [ ! -f "$HOME/.zshrc.local" ] && [ -f "$DOTFILES_DIR/templates/zshrc.local.template" ]; then
        cp "$DOTFILES_DIR/templates/zshrc.local.template" "$HOME/.zshrc.local"
        info "Created ~/.zshrc.local from template - customize as needed"
    fi
}

# Verify installation
verify_installation() {
    log "Verifying installation..."
    
    # Check symlinks
    local configs=(".zshrc" ".gitconfig" ".p10k.zsh" ".vimrc" ".tmux.conf")
    for config in "${configs[@]}"; do
        if [ -L "$HOME/$config" ]; then
            info "✓ $config is properly symlinked"
        else
            warn "✗ $config is not symlinked"
        fi
    done
    
    # Check git config
    if git config --global user.name >/dev/null 2>&1; then
        local git_user=$(git config --global user.name)
        local git_email=$(git config --global user.email)
        info "✓ Git configured: $git_user <$git_email>"
    else
        warn "✗ Git configuration not found"
    fi
    
    # Test ZSH config
    if zsh -c "source ~/.zshrc; echo 'ZSH loads successfully'" >/dev/null 2>&1; then
        info "✓ ZSH configuration loads successfully"
    else
        warn "✗ ZSH configuration has issues"
    fi
}

# Main installation function
main() {
    log "Starting modern dotfiles installation..."
    
    # Check if we're in the dotfiles directory
    if [ ! -f "$DOTFILES_DIR/install.sh" ]; then
        error "Please run this script from your dotfiles directory"
    fi
    
    backup_existing
    install_packages
    setup_zsh
    create_symlinks
    setup_directories
    setup_templates
    verify_installation
    
    log "Installation completed successfully!"
    info ""
    info "Next steps:"
    info "1. Restart your terminal or run: source ~/.zshrc"
    info "2. Customize ~/.zshrc.local for environment-specific settings"
    info "3. Set up SSH config from template if needed"
    info "4. Enjoy your new dotfiles setup!"
    
    if [ -d "$BACKUP_DIR" ]; then
        info ""
        info "Your old dotfiles are backed up in: $BACKUP_DIR"
    fi
}

# Run main function
main "$@"