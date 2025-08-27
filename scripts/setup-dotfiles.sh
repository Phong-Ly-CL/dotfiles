#!/bin/bash

# Dotfiles Setup Script for Codespaces
# Sets up development environment to match local PC configuration
# Author: Phong Ly
# Usage: ./setup-dotfiles.sh

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
DOTFILES_REPO="https://github.com/Phong-Ly-CL/dotfiles.git"
DOTFILES_DIR="$HOME/dotfiles"

# Logging function
log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')] $1${NC}"
}

warn() {
    echo -e "${YELLOW}[WARNING] $1${NC}"
}

error() {
    echo -e "${RED}[ERROR] $1${NC}"
    exit 1
}

info() {
    echo -e "${BLUE}[INFO] $1${NC}"
}

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Main setup function
main() {
    log "Starting dotfiles setup for Codespaces..."
    
    # Update system packages
    log "Updating system packages..."
    sudo apt update || warn "Failed to update package list"
    
    # Clone dotfiles repository
    log "Cloning dotfiles repository..."
    clone_dotfiles
    
    # Install required packages
    log "Installing required packages..."
    install_packages
    
    # Setup oh-my-zsh and plugins
    log "Setting up oh-my-zsh and plugins..."
    setup_zsh
    
    # Copy configuration files
    log "Copying configuration files..."
    copy_configs
    
    # Verify installation
    log "Verifying installation..."
    verify_setup
    
    log "Dotfiles setup completed successfully!"
    info "To start using zsh with your configuration, run: zsh"
    info "Your git aliases are now available (try 'git st' or 'git lg')"
}

# Clone dotfiles repository
clone_dotfiles() {
    if [ -d "$DOTFILES_DIR" ]; then
        warn "Dotfiles directory already exists. Removing and re-cloning..."
        rm -rf "$DOTFILES_DIR"
    fi
    
    if ! git clone "$DOTFILES_REPO" "$DOTFILES_DIR"; then
        error "Failed to clone dotfiles repository"
    fi
    
    info "Dotfiles cloned to $DOTFILES_DIR"
}

# Install required packages
install_packages() {
    local packages=("bat" "lsd" "htop" "zsh")
    
    for package in "${packages[@]}"; do
        if ! command_exists "$package"; then
            info "Installing $package..."
            sudo apt install -y "$package" || warn "Failed to install $package"
        else
            info "$package is already installed"
        fi
    done
}

# Setup oh-my-zsh and plugins
setup_zsh() {
    # Check if oh-my-zsh is already installed
    if [ ! -d "$HOME/.oh-my-zsh" ]; then
        info "oh-my-zsh not found, but it should be pre-installed in Codespaces"
        warn "Continuing anyway..."
    else
        info "oh-my-zsh is already installed"
    fi
    
    # Install zsh-autosuggestions plugin
    local autosuggestions_dir="$HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions"
    if [ ! -d "$autosuggestions_dir" ]; then
        info "Installing zsh-autosuggestions plugin..."
        git clone https://github.com/zsh-users/zsh-autosuggestions "$autosuggestions_dir" || warn "Failed to install zsh-autosuggestions"
    else
        info "zsh-autosuggestions plugin already installed"
    fi
    
    # Install zsh-syntax-highlighting plugin
    local syntax_highlighting_dir="$HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting"
    if [ ! -d "$syntax_highlighting_dir" ]; then
        info "Installing zsh-syntax-highlighting plugin..."
        git clone https://github.com/zsh-users/zsh-syntax-highlighting "$syntax_highlighting_dir" || warn "Failed to install zsh-syntax-highlighting"
    else
        info "zsh-syntax-highlighting plugin already installed"
    fi
    
    # Install Powerlevel10k theme
    local p10k_dir="$HOME/.oh-my-zsh/custom/themes/powerlevel10k"
    if [ ! -d "$p10k_dir" ]; then
        info "Installing Powerlevel10k theme..."
        git clone https://github.com/romkatv/powerlevel10k.git "$p10k_dir" || warn "Failed to install Powerlevel10k"
    else
        info "Powerlevel10k theme already installed"
    fi
}

# Copy configuration files
copy_configs() {
    local configs=("gitconfig:.gitconfig" "zshrc:.zshrc" "p10k.zsh:.p10k.zsh")
    
    for config in "${configs[@]}"; do
        local source_file="${config%:*}"
        local target_file="${config#*:}"
        local source_path="$DOTFILES_DIR/$source_file"
        local target_path="$HOME/$target_file"
        
        if [ -f "$source_path" ]; then
            info "Copying $source_file to $target_file"
            cp "$source_path" "$target_path" || warn "Failed to copy $source_file"
        else
            warn "Source file $source_path not found"
        fi
    done
}

# Verify setup
verify_setup() {
    info "Verifying git configuration..."
    if git config --global user.name >/dev/null 2>&1; then
        local git_user=$(git config --global user.name)
        local git_email=$(git config --global user.email)
        info "Git user: $git_user <$git_email>"
    else
        warn "Git configuration not found"
    fi
    
    info "Verifying zsh configuration..."
    if [ -f "$HOME/.zshrc" ]; then
        info "ZSH configuration file exists"
    else
        warn "ZSH configuration file not found"
    fi
    
    info "Verifying installed tools..."
    local tools=("batcat" "lsd" "htop")
    for tool in "${tools[@]}"; do
        if command_exists "$tool"; then
            info "$tool is available"
        else
            warn "$tool is not available"
        fi
    done
    
    info "Testing zsh configuration..."
    if zsh -c "source ~/.zshrc; echo 'ZSH configuration loaded successfully'" 2>/dev/null; then
        info "ZSH configuration loads successfully"
    else
        warn "ZSH configuration has some warnings (this is normal for missing tools)"
    fi
}

# Cleanup function
cleanup() {
    if [ $? -ne 0 ]; then
        error "Setup failed. Please check the error messages above."
    fi
}

# Set trap for cleanup
trap cleanup EXIT

# Run main function
main "$@"
