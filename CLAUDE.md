# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a personal dotfiles repository for macOS. It contains shell configuration, editor settings, and system preferences. Files are meant to be symlinked or copied to `$HOME`.

## Files

- `.zshrc` — Zsh shell config: oh-my-zsh (agnoster theme), plugins, PATH setup, aliases, and shell functions. Sources `~/.aliases` if present (gitignored, for local/sensitive overrides).
- `.gitconfig` — Git settings, aliases, and editor config (vi).
- `.vimrc` — Vim settings: 2-space indentation, syntax highlighting, 80-col indicator, NERDTree binding.
- `.inputrc` — Readline config.
- `.osx` — macOS system preference automation script (run once on new machines).

## Key Conventions

- Secrets and machine-local config (API keys, SSH aliases) belong in `~/.aliases`, which is not tracked by git.
- The `.osx` script is run manually to configure macOS defaults — it is not idempotent in all cases, so review before re-running.
- `.gitconfig` contains placeholder user info (`Jeff Geerling`) — update after cloning.

## Security Note

Never commit API keys or secrets to `.zshrc` or any tracked file. Use `~/.aliases` (sourced by `.zshrc` and gitignored) for any environment-specific credentials.
