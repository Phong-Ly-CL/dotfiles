#!/bin/bash

# Modern Dotfiles Installation Script
# Uses symlinks instead of copying for easier updates
# Author: Phong Ly

# Temporarily disable strict mode for debugging
set -eo pipefail  # Exit on error and pipe failures, but allow undefined variables

# Error handler
trap 'error_handler $? $LINENO' ERR

error_handler() {
    local exit_code=$1
    local line_number=$2
    error "Script failed at line $line_number with exit code $exit_code"
}

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
    info "Checking for existing dotfiles to backup..."
    local files=(".zshrc" ".gitconfig" ".p10k.zsh" ".vimrc" ".tmux.conf")
    local backed_up=false
    
    # Debug: Show backup directory
    info "Backup directory would be: $BACKUP_DIR"
    
    for file in "${files[@]}"; do
        info "Checking $HOME/$file..."
        if [ -f "$HOME/$file" ] && [ ! -L "$HOME/$file" ]; then
            if [ "$backed_up" = false ]; then
                info "Creating backup directory: $BACKUP_DIR"
                if ! mkdir -p "$BACKUP_DIR"; then
                    error "Failed to create backup directory: $BACKUP_DIR"
                fi
                backed_up=true
            fi
            info "Backing up $file..."
            if ! cp "$HOME/$file" "$BACKUP_DIR/"; then
                error "Failed to backup $file to $BACKUP_DIR"
            fi
            info "✓ Successfully backed up $file"
        else
            info "Skipping $file (not found or already symlinked)"
        fi
    done
    
    if [ "$backed_up" = true ]; then
        info "✓ Existing dotfiles backed up to $BACKUP_DIR"
    else
        info "✓ No files needed backup"
    fi
}

# Create symlinks
create_symlinks() {
    local configs=(
        "configs/zsh/zshrc:.zshrc"
        "configs/git/gitconfig:.gitconfig" 
        "configs/zsh/p10k.zsh:.p10k.zsh"
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
    
    # Determine package manager and packages
    if command_exists apt; then
        info "Using apt package manager..."
        if command -v sudo >/dev/null 2>&1; then
            info "Updating package list..."
            if ! sudo apt update 2>/dev/null; then
                warn "Failed to update package list (continuing anyway)"
            fi
        else
            warn "No sudo access, skipping package update"
        fi
        local packages=("bat" "lsd" "htop" "zsh" "tmux" "vim")
    elif command_exists yum; then
        info "Using yum package manager..."
        local packages=("bat" "htop" "zsh" "tmux" "vim")
    elif command_exists brew; then
        info "Using brew package manager..."
        local packages=("bat" "lsd" "htop" "zsh" "tmux" "vim")
    else
        warn "No supported package manager found, skipping package installation"
        return 0
    fi
    
    for package in "${packages[@]}"; do
        if ! command_exists "$package"; then
            info "Installing $package..."
            local install_success=false
            
            if command_exists apt; then
                if command -v sudo >/dev/null 2>&1; then
                    if sudo apt install -y "$package" 2>/dev/null; then
                        install_success=true
                    fi
                else
                    warn "No sudo access, cannot install $package"
                fi
            elif command_exists yum; then
                if sudo yum install -y "$package" 2>/dev/null; then
                    install_success=true
                fi
            elif command_exists brew; then
                if brew install "$package" 2>/dev/null; then
                    install_success=true
                fi
            fi
            
            if [ "$install_success" = true ]; then
                info "✓ Successfully installed $package"
            else
                warn "✗ Failed to install $package (continuing anyway)"
            fi
        else
            info "✓ $package already installed"
        fi
    done
}

# Setup ZSH plugins
setup_zsh() {
    log "Setting up ZSH plugins..."
    
    # Install oh-my-zsh if not present
    if [ ! -d "$HOME/.oh-my-zsh" ]; then
        info "Installing oh-my-zsh..."
        export RUNZSH=no
        export CHSH=no
        sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" || warn "Failed to install oh-my-zsh"
    else
        info "✓ oh-my-zsh already installed"
    fi
    
    # Verify oh-my-zsh core files
    if [ -f "$HOME/.oh-my-zsh/oh-my-zsh.sh" ]; then
        info "✓ oh-my-zsh core file verified"
    else
        warn "✗ oh-my-zsh core file missing: $HOME/.oh-my-zsh/oh-my-zsh.sh"
    fi
    
    # Ensure custom directories exist
    mkdir -p "$HOME/.oh-my-zsh/custom/plugins"
    mkdir -p "$HOME/.oh-my-zsh/custom/themes"
    
    # Install plugins with error handling
    local plugins=(
        "zsh-autosuggestions:https://github.com/zsh-users/zsh-autosuggestions.git"
        "zsh-syntax-highlighting:https://github.com/zsh-users/zsh-syntax-highlighting.git"
    )
    
    for plugin in "${plugins[@]}"; do
        local plugin_name="${plugin%:*}"
        local plugin_repo="${plugin#*:}"
        local plugin_dir="$HOME/.oh-my-zsh/custom/plugins/$plugin_name"
        
        if [ ! -d "$plugin_dir" ]; then
            info "Installing $plugin_name..."
            if git clone "$plugin_repo" "$plugin_dir"; then
                info "✓ Successfully installed $plugin_name"
            else
                warn "✗ Failed to install $plugin_name"
            fi
        else
            info "✓ $plugin_name already installed"
            # Verify plugin files exist (different plugins use different naming)
            local plugin_file_found=false
            
            # Check for common plugin file patterns
            if [ -f "$plugin_dir/${plugin_name}.plugin.zsh" ]; then
                info "  Plugin file verified: ${plugin_name}.plugin.zsh"
                plugin_file_found=true
            elif [ -f "$plugin_dir/${plugin_name}.zsh" ]; then
                info "  Plugin file verified: ${plugin_name}.zsh"
                plugin_file_found=true
            elif [ -f "$plugin_dir/$(basename $plugin_name).plugin.zsh" ]; then
                info "  Plugin file verified: $(basename $plugin_name).plugin.zsh"
                plugin_file_found=true
            fi
            
            if [ "$plugin_file_found" = false ]; then
                warn "  No standard plugin files found"
                info "  Directory contents:"
                ls -la "$plugin_dir" | head -5
                
                # For zsh-autosuggestions and zsh-syntax-highlighting, create plugin files if main files exist
                if [ "$plugin_name" = "zsh-autosuggestions" ] && [ -f "$plugin_dir/zsh-autosuggestions.zsh" ]; then
                    info "  Found main file: zsh-autosuggestions.zsh"
                    if [ ! -f "$plugin_dir/zsh-autosuggestions.plugin.zsh" ]; then
                        info "  Creating plugin wrapper file..."
                        echo "source \"\${0:A:h}/zsh-autosuggestions.zsh\"" > "$plugin_dir/zsh-autosuggestions.plugin.zsh"
                        info "  ✓ Created zsh-autosuggestions.plugin.zsh"
                    fi
                elif [ "$plugin_name" = "zsh-syntax-highlighting" ] && [ -f "$plugin_dir/zsh-syntax-highlighting.zsh" ]; then
                    info "  Found main file: zsh-syntax-highlighting.zsh"
                    if [ ! -f "$plugin_dir/zsh-syntax-highlighting.plugin.zsh" ]; then
                        info "  Creating plugin wrapper file..."
                        echo "source \"\${0:A:h}/zsh-syntax-highlighting.zsh\"" > "$plugin_dir/zsh-syntax-highlighting.plugin.zsh"
                        info "  ✓ Created zsh-syntax-highlighting.plugin.zsh"
                    fi
                fi
            fi
        fi
    done
    
    # Install Powerlevel10k theme
    local p10k_dir="$HOME/.oh-my-zsh/custom/themes/powerlevel10k"
    if [ ! -d "$p10k_dir" ]; then
        info "Installing Powerlevel10k theme..."
        if git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$p10k_dir"; then
            info "✓ Successfully installed Powerlevel10k"
        else
            warn "✗ Failed to install Powerlevel10k"
        fi
    else
        info "✓ Powerlevel10k already installed"
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
    
    # Test ZSH config with timeout
    info "Testing ZSH configuration..."
    if timeout 10s zsh -c "export POWERLEVEL9K_INSTANT_PROMPT=off; source ~/.zshrc; echo 'ZSH loads successfully'" >/dev/null 2>&1; then
        info "✓ ZSH configuration loads successfully"
    else
        warn "✗ ZSH configuration test timed out or failed (this is often normal)"
        info "  Try running 'source ~/.zshrc' manually to test"
    fi
}

# Main installation function
main() {
    log "Starting modern dotfiles installation..."
    
    # Debug: Show environment
    info "Debug: HOME=$HOME"
    info "Debug: DOTFILES_DIR=$DOTFILES_DIR"
    info "Debug: BACKUP_DIR=$BACKUP_DIR"
    
    # Check if we're in the dotfiles directory
    if [ ! -f "$DOTFILES_DIR/install.sh" ]; then
        error "Please run this script from your dotfiles directory"
    fi
    
    log "Step 1: Creating backups..."
    backup_existing
    
    log "Step 2: Installing packages..."
    install_packages
    
    log "Step 3: Setting up ZSH..."
    setup_zsh
    
    log "Step 4: Creating symlinks..."
    create_symlinks
    
    log "Step 5: Setting up directories..."
    setup_directories
    
    log "Step 6: Setting up templates..."
    setup_templates
    
    log "Step 7: Verifying installation..."
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