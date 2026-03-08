#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES=(.zshrc .gitconfig .vimrc .inputrc .tmux.conf)
TIMESTAMP=$(date +%Y%m%d-%H%M%S)

# ---------------------------------------------------------------------------
# Plugins
# ---------------------------------------------------------------------------

echo "Installing plugins..."
echo ""

# oh-my-zsh
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  echo "  install oh-my-zsh"
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
else
  echo "  skip   oh-my-zsh (already installed)"
fi

ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

# fzf (binary — the omz plugin wraps this)
if ! command -v fzf &>/dev/null; then
  echo "  install fzf"
  brew install fzf
else
  echo "  skip   fzf (already installed)"
fi

# zsh-autosuggestions
if [ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
  echo "  install zsh-autosuggestions"
  git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
else
  echo "  skip   zsh-autosuggestions (already installed)"
fi

# zsh-syntax-highlighting
if [ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]; then
  echo "  install zsh-syntax-highlighting"
  git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
else
  echo "  skip   zsh-syntax-highlighting (already installed)"
fi

echo ""

# ---------------------------------------------------------------------------
# Dotfiles
# ---------------------------------------------------------------------------

echo "Symlinking dotfiles from $DOTFILES_DIR..."
echo ""

for dotfile in "${DOTFILES[@]}"; do
  src="$DOTFILES_DIR/$dotfile"
  dest="$HOME/$dotfile"

  if [ ! -f "$src" ]; then
    echo "  skip   $dotfile (not found in repo)"
    continue
  fi

  if [ -L "$dest" ] && [ "$(readlink "$dest")" = "$src" ]; then
    echo "  skip   $dotfile (already symlinked)"
    continue
  fi

  if [ -e "$dest" ] || [ -L "$dest" ]; then
    backup="$dest.backup.$TIMESTAMP"
    mv "$dest" "$backup"
    echo "  backup $dotfile → $backup"
  fi

  ln -s "$src" "$dest"
  echo "  link   $dotfile → $src"
done

echo ""

# ---------------------------------------------------------------------------
# Claude configs
# ---------------------------------------------------------------------------

echo "Symlinking Claude configs..."
echo ""

CLAUDE_FILES=(settings.json statusline-command.sh)
mkdir -p "$HOME/.claude"

for file in "${CLAUDE_FILES[@]}"; do
  src="$DOTFILES_DIR/.claude/$file"
  dest="$HOME/.claude/$file"

  if [ ! -f "$src" ]; then
    echo "  skip   .claude/$file (not found in repo)"
    continue
  fi

  if [ -L "$dest" ] && [ "$(readlink "$dest")" = "$src" ]; then
    echo "  skip   .claude/$file (already symlinked)"
    continue
  fi

  if [ -e "$dest" ] || [ -L "$dest" ]; then
    backup="$dest.backup.$TIMESTAMP"
    mv "$dest" "$backup"
    echo "  backup .claude/$file → $backup"
  fi

  ln -s "$src" "$dest"
  echo "  link   .claude/$file → $src"
done

echo ""
echo "Done."
echo ""
echo "Reminder: OPENAI_API_KEY should be in ~/.aliases (gitignored) via 1Password:"
echo "  export OPENAI_API_KEY=\$(op item get \"openai_apikey\" --fields credential)"
