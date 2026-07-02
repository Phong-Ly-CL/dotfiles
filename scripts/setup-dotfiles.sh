#!/bin/bash

# Dotfiles Bootstrap Script
# Clones the repo (or updates it) and runs the main installer.
# Safe to curl-pipe on a fresh machine or Codespace:
#   curl -fsSL https://raw.githubusercontent.com/Phong-Ly-CL/dotfiles/master/scripts/setup-dotfiles.sh | bash

set -e

DOTFILES_REPO="https://github.com/Phong-Ly-CL/dotfiles.git"
DOTFILES_DIR="$HOME/.dotfiles"

if [ -d "$DOTFILES_DIR/.git" ]; then
    echo "Dotfiles already cloned, pulling latest..."
    git -C "$DOTFILES_DIR" pull --ff-only
else
    echo "Cloning dotfiles to $DOTFILES_DIR..."
    git clone "$DOTFILES_REPO" "$DOTFILES_DIR"
fi

exec "$DOTFILES_DIR/install.sh"
