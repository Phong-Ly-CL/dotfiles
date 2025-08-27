#!/bin/bash

# One-liner setup script for new Codespaces
# Usage: curl -s https://raw.githubusercontent.com/Phong-Ly-CL/dotfiles/master/quick-setup.sh | bash

echo "🚀 Setting up your Codespace with dotfiles..."

# Download and run the main setup script
curl -s https://raw.githubusercontent.com/Phong-Ly-CL/dotfiles/master/setup-dotfiles.sh | bash

echo "✨ Setup complete! Run 'zsh' to start using your configured shell."
