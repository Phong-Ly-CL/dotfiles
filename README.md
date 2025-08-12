# Dotfiles Setup Script

This script automatically sets up your Codespace to match your local PC development environment using your dotfiles repository.

## Quick Setup

For new Codespaces, run this single command:

```bash
bash <(curl -s https://raw.githubusercontent.com/Phong-Ly-CL/dotfiles/master/setup-dotfiles.sh)
```

Or if you're already in this repository:

```bash
./setup-dotfiles.sh
```

## What the Script Does

✅ **System Updates**

- Updates package lists

✅ **Dotfiles Repository**

- Clones your dotfiles from `https://github.com/Phong-Ly-CL/dotfiles.git`
- Handles existing installations gracefully

✅ **Package Installation**

- Installs: `bat`, `lsd`, `htop`, `zsh`
- Skips already installed packages

✅ **Shell Configuration**

- Sets up oh-my-zsh (if not already present)
- Installs zsh-autosuggestions plugin
- Installs zsh-syntax-highlighting plugin
- Installs Powerlevel10k theme

✅ **Configuration Files**

- Copies `.gitconfig` with all your git aliases
- Copies `.zshrc` with shell customizations
- Copies `.p10k.zsh` for Powerlevel10k theme

✅ **Verification**

- Tests all configurations
- Reports any issues

## After Installation

1. **Start using zsh**: Run `zsh` to switch to your configured shell
2. **Test git aliases**: Try `git st` (status) or `git lg` (fancy log)
3. **Enjoy enhanced tools**: `ls` now uses `lsd`, `cat` uses `batcat`

## Troubleshooting

The script includes comprehensive error handling and colored output:

- 🟢 **Green**: Successful operations
- 🟡 **Yellow**: Warnings (non-critical)
- 🔴 **Red**: Errors (will stop execution)
- 🔵 **Blue**: Information messages

## Manual Installation

If you prefer to run the script locally:

1. Download the script:

   ```bash
   wget https://raw.githubusercontent.com/Phong-Ly-CL/dotfiles/master/setup-dotfiles.sh
   ```

2. Make it executable:

   ```bash
   chmod +x setup-dotfiles.sh
   ```

3. Run it:
   ```bash
   ./setup-dotfiles.sh
   ```

## Notes

- The script is idempotent (safe to run multiple times)
- Some warnings about missing Homebrew/Go are normal and expected
- Default shell change requires admin privileges (not available in Codespaces)
- All your custom aliases and configurations will be preserved
