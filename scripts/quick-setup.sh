#!/bin/bash

# One-liner setup script for new machines and Codespaces
# Usage: curl -fsSL https://raw.githubusercontent.com/phongly3112/dotfiles/master/scripts/quick-setup.sh | bash

echo "🚀 Setting up your environment with dotfiles..."

curl -fsSL https://raw.githubusercontent.com/phongly3112/dotfiles/master/scripts/setup-dotfiles.sh | bash

echo "✨ Setup complete! Run 'zsh' to start using your configured shell."
