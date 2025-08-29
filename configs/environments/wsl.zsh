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

# VS Code integration - use WSL VS Code Server if available
vscode_server_path=$(find "$HOME/.vscode-server/bin" -name "remote-cli" -type d 2>/dev/null | head -1)
if [[ -n "$vscode_server_path" ]]; then
    # Add VS Code Server to PATH
    export PATH="$vscode_server_path:$PATH"
    unalias code 2>/dev/null || true
elif [[ -f "/usr/bin/code" ]]; then
    # Native Linux VS Code exists
    unalias code 2>/dev/null || true
else
    # Fallback to Windows VS Code
    unalias code 2>/dev/null || true
    code() {
        "/mnt/c/Users/ly.phong/AppData/Local/Programs/Microsoft VS Code/Code.exe" "$@"
    }
fi

# Windows path integration
export PATH="$PATH:/mnt/c/Windows/System32"

# Info message
echo "🪟 WSL environment loaded"