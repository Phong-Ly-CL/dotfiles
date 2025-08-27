# Dotfiles Makefile
.PHONY: help install uninstall backup clean test update

# Default target
help:
	@echo "Dotfiles Management"
	@echo ""
	@echo "Available targets:"
	@echo "  install    - Install dotfiles with symlinks"
	@echo "  uninstall  - Remove symlinks and restore backups"
	@echo "  backup     - Create backup of current dotfiles"
	@echo "  clean      - Clean up temporary files"
	@echo "  test       - Test configuration files"
	@echo "  update     - Update dotfiles from git and reinstall"
	@echo "  help       - Show this help message"

install:
	@echo "Installing dotfiles..."
	@./install.sh

uninstall:
	@echo "Uninstalling dotfiles..."
	@./scripts/uninstall.sh

backup:
	@echo "Creating backup..."
	@./scripts/backup.sh

clean:
	@echo "Cleaning up..."
	@find . -name "*.tmp" -delete
	@find . -name "*.log" -delete
	@find . -name ".DS_Store" -delete

test:
	@echo "Testing configurations..."
	@zsh -n configs/zshrc && echo "✓ zshrc syntax OK"
	@tmux -f configs/tmux/tmux.conf list-keys > /dev/null && echo "✓ tmux config OK"
	@vim -T dumb -n -i NONE -es -S configs/vim/vimrc +qall && echo "✓ vim config OK"

update:
	@echo "Updating dotfiles..."
	@git pull origin main
	@./install.sh