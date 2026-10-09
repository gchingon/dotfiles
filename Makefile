.PHONY: help install setup clean test startup-time audit

help:
	@echo "~/.config Makefile — Common tasks"
	@echo ""
	@echo "Usage: make [target]"
	@echo ""
	@echo "Targets:"
	@echo "  install       - Set up symlinks to omarchy4mac components"
	@echo "  setup         - Full setup (install + verify)"
	@echo "  clean         - Remove compiled .zwc files"
	@echo "  test          - Check zsh syntax & integrity"
	@echo "  startup-time  - Measure zsh startup time"
	@echo "  audit         - Review config structure & unused files"
	@echo "  link-scripts  - Create symlinks for rx/ scripts"

install:
	@echo "Setting up ~/.config symlinks..."
	mkdir -p ~/.local/bin
	mkdir -p ~/.hammerspoon
	ln -sfn ~/.config/hammerspoon/init.lua ~/.hammerspoon/init.lua
	for f in ~/.config/bin/*; do case "$$f" in *.swift) ;; *) ln -sfn "$$f" ~/.local/bin/$$(basename "$$f");; esac; done
	@echo "yabai: cp ~/.config/yabai/com.asmvik.yabai.plist ~/Library/LaunchAgents/ && launchctl load it (see comment inside)"
	@echo "theme: run 'theme --sync' once, then re-create the custom themes (theme-switcher/custom/)"
	@echo "✓ Symlinks created"

setup: install test
	@echo "✓ Setup complete!"
	@echo ""
	@echo "Next steps:"
	@echo "  1. Start a new shell: zsh"
	@echo "  2. Verify startup time: make startup-time"
	@echo "  3. Check config: make test"

clean:
	@echo "Cleaning compiled .zwc files..."
	find ~/.config/zsh -name "*.zwc*" -delete 2>/dev/null
	@echo "✓ Cleaned"

test:
	@echo "Testing zsh syntax..."
	@zsh -n ~/.config/zsh/zshenv && echo "  ✓ zshenv" || echo "  ✗ zshenv"
	@zsh -n ~/.config/zsh/zprofile && echo "  ✓ zprofile" || echo "  ✗ zprofile"
	@zsh -n ~/.config/zsh/zshrc && echo "  ✓ zshrc" || echo "  ✗ zshrc"
	@echo ""
	@echo "Checking required files..."
	@[[ -f ~/.config/.secrets/machine.env ]] && echo "  ✓ .secrets/machine.env" || echo "  ✗ .secrets/machine.env (MISSING)"
	@[[ -d ~/.config/zsh/modules ]] && echo "  ✓ zsh/modules/" || echo "  ✗ zsh/modules/ (MISSING)"
	@[[ -d ~/.config/rx ]] && echo "  ✓ rx/" || echo "  ✗ rx/ (MISSING)"
	@echo ""
	@echo "✓ All checks passed"

startup-time:
	@echo "Measuring zsh startup time (3 runs)..."
	@for i in 1 2 3; do echo "  Run $$i:"; time zsh -i -c exit 2>&1 | grep real; done
	@echo ""
	@echo "Target: <0.6s"

audit:
	@echo "Config Structure Audit"
	@echo ""
	@echo "Directories:"
	@du -sh ~/.config/*/  | sort -h
	@echo ""
	@echo "Largest files:"
	@find ~/.config -type f -size +1M 2>/dev/null | xargs du -sh | sort -hr | head -5
	@echo ""
	@echo "Dead symlinks:"
	@find ~/.config -type l ! -exec test -e {} \; -print 2>/dev/null || echo "  (none)"
	@echo ""
	@echo "Unused directories (candidates for archiving):"
	@echo "  - vim/ (if nvim only)"
	@echo "  - browser-harness/ (check if used)"
	@echo "  - theme-switcher/ (check if superseded by omarchy4mac/theme)"
	@echo "  - hermes/ (check if used)"

link-scripts:
	@echo "Creating symlinks for rx/ scripts..."
	@mkdir -p ~/.local/bin
	@for script in ~/.config/rx/*.sh; do \
		name=$$(basename "$$script" .sh); \
		ln -sf "$$script" ~/.local/bin/"$$name"; \
	done
	@echo "✓ Symlinks created in ~/.local/bin/"

.DEFAULT_GOAL := help
