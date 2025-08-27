# WSL-specific ZSH configuration
# Source this file from ~/.zshrc.local when in WSL

# WSL aliases
alias open='explorer.exe'
alias clip='clip.exe'
alias pbcopy='clip.exe'
alias pbpaste='powershell.exe Get-Clipboard | tr -d "\r"'

# Windows integration
alias windows='/mnt/c'
alias desktop='/mnt/c/Users/$USER/Desktop'
alias downloads='/mnt/c/Users/$USER/Downloads'

# WSL environment variables
export DISPLAY=$(awk '/nameserver / {print $2; exit}' /etc/resolv.conf 2>/dev/null):0
export LIBGL_ALWAYS_INDIRECT=1

# Docker Desktop integration
if [[ -f "/mnt/c/Program Files/Docker/Docker/resources/bin/docker.exe" ]]; then
    alias docker='docker.exe'
    alias docker-compose='docker-compose.exe'
fi

# VS Code integration
if command -v code.cmd > /dev/null; then
    alias code='code.cmd'
fi

# Windows path integration
export PATH="$PATH:/mnt/c/Windows/System32"

# Info message
echo "🪟 WSL environment loaded"