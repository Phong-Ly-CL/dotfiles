# New Machine Migration Checklist

Steps to get a new PC (or WSL instance / Codespace) to full working state.
The dotfiles themselves are step 1; the rest is tooling and credentials
that can't or shouldn't live in this repo.

## 1. Dotfiles

```bash
git clone https://github.com/Phong-Ly-CL/dotfiles.git ~/.dotfiles
~/.dotfiles/install.sh
```

This installs zsh/oh-my-zsh/p10k, base CLI tools (`bat`, `lsd`, `htop`,
`tmux`, `vim`), and symlinks all configs including Claude Code.
Then restart the terminal (or `exec zsh`).

- [ ] `install.sh` ran without errors
- [ ] Customize `~/.zshrc.local` if this machine needs specific aliases/paths

## 2. Dev toolchain

The zshrc references these but does not install them:

- [ ] **nvm + Node** —
  ```bash
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
  nvm install 25 && nvm alias default 25
  ```
- [ ] **Go** — `sudo apt install golang-go` (or download from https://go.dev/dl/ for latest)
- [ ] **.NET SDK** — https://dotnet.microsoft.com/download (installs to `~/.dotnet`, already on PATH via zshrc)
- [ ] **Java 17** — via Homebrew: `brew install openjdk@17` (zshrc expects the linuxbrew path)
- [ ] **Homebrew (Linux)** — https://brew.sh (zshrc auto-detects `/home/linuxbrew/.linuxbrew`)
- [ ] **Terraform** — https://developer.hashicorp.com/terraform/install
- [ ] **Docker** — on WSL: install Docker Desktop on Windows, enable WSL integration
- [ ] **GitHub CLI** — `sudo apt install gh`
- [ ] **Azure CLI** — `curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash`
- [ ] **AWS CLI** — https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html
- [ ] **SQL Server tools** (if needed) — mssql-tools to `/opt/mssql-tools` (already on PATH via zshrc)

## 3. Credentials & auth

Never in the repo — always set up fresh or copied securely:

- [ ] **SSH keys** — copy `~/.ssh/id_*` from old machine (or generate new and update GitHub/servers), `chmod 600`
- [ ] **SSH config** — `cp ~/.dotfiles/configs/ssh/config.template ~/.ssh/config` and fill in hosts
- [ ] `gh auth login`
- [ ] `az login`
- [ ] `aws configure`
- [ ] **Claude Code** — run `claude` and log in
- [ ] Git credentials for any private remotes (gh handles GitHub)

## 4. WSL-specific (lives on the Windows side)

- [ ] `.wslconfig` in the Windows user profile (memory/CPU limits)
- [ ] Windows Terminal settings (font: a Nerd Font for p10k icons, color scheme)
- [ ] VS Code: install the WSL extension; settings come via built-in **Settings Sync** (sign in), not dotfiles

## 5. Verify

- [ ] New terminal starts fast and p10k prompt renders correctly
- [ ] `node --version` works without running `nvm` first (lazy-load PATH injection)
- [ ] `git st` / `git lg` aliases work
- [ ] `make test` in `~/.dotfiles` passes
- [ ] Claude Code statusline shows model/cost/context (and usage bars once on Pro/Max)
