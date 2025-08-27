# Codespaces-specific ZSH configuration
# Source this file from ~/.zshrc.local when in Codespaces

# Codespaces aliases
alias cde='cd /workspaces/claudio_erp_plus'
alias cdx='cd /workspaces/xymax-aries'
alias cdxb='cd /workspaces/xymax-aries-batch'
alias cdp='cd /workspaces/personal_work'

# Codespaces environment variables
export BROWSER="none"  # Prevent browser launching in Codespaces
export EDITOR="code --wait"

# Codespaces-specific settings
export GPG_TTY=$(tty)

# Docker in Codespaces
if command -v docker > /dev/null; then
    # Docker completion
    if [ -f /usr/share/bash-completion/completions/docker ]; then
        source /usr/share/bash-completion/completions/docker
    fi
fi

# Node.js settings for Codespaces
export NODE_OPTIONS="--max-old-space-size=4096"

# Info message
echo "🚀 Codespaces environment loaded"