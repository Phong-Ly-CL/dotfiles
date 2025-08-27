# macOS-specific ZSH configuration
# Source this file from ~/.zshrc.local when on macOS

# macOS aliases
alias ls='ls -G'  # Use macOS color option
alias showfiles='defaults write com.apple.finder AppleShowAllFiles YES; killall Finder'
alias hidefiles='defaults write com.apple.finder AppleShowAllFiles NO; killall Finder'

# Homebrew
if [[ -f "/opt/homebrew/bin/brew" ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -f "/usr/local/bin/brew" ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
fi

# macOS development tools
export CPPFLAGS="-I/opt/homebrew/include"
export LDFLAGS="-L/opt/homebrew/lib"

# Quick Look
alias ql='qlmanage -p'

# Xcode
alias xcode='open -a Xcode'
alias simulator='open -a Simulator'

# System shortcuts
alias sleepnow='pmset sleepnow'
alias restart='sudo shutdown -r now'
alias shutdown='sudo shutdown -h now'

# Info message
echo "🍎 macOS environment loaded"