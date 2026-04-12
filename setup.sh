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

# catppuccin-zsh oh-my-zsh theme (JannoTjarks/catppuccin-zsh)
CATPPUCCIN_ZSH_DIR="$ZSH_CUSTOM/themes/catppuccin-zsh"
if [ ! -d "$CATPPUCCIN_ZSH_DIR" ]; then
  echo "  install catppuccin-zsh theme"
  git clone --depth=1 https://github.com/JannoTjarks/catppuccin-zsh.git "$CATPPUCCIN_ZSH_DIR"
else
  echo "  skip   catppuccin-zsh theme (already cloned)"
fi

# Expose theme file + flavors dir under $ZSH_CUSTOM/themes so oh-my-zsh can find them.
if [ ! -L "$ZSH_CUSTOM/themes/catppuccin.zsh-theme" ]; then
  ln -sf "$CATPPUCCIN_ZSH_DIR/catppuccin.zsh-theme" "$ZSH_CUSTOM/themes/catppuccin.zsh-theme"
  echo "  link   catppuccin.zsh-theme"
else
  echo "  skip   catppuccin.zsh-theme (already linked)"
fi
if [ ! -L "$ZSH_CUSTOM/themes/catppuccin-flavors" ]; then
  ln -sf "$CATPPUCCIN_ZSH_DIR/catppuccin-flavors" "$ZSH_CUSTOM/themes/catppuccin-flavors"
  echo "  link   catppuccin-flavors/"
else
  echo "  skip   catppuccin-flavors/ (already linked)"
fi

# catppuccin for tmux
if [ ! -d "$HOME/.config/tmux/plugins/catppuccin/tmux" ]; then
  echo "  install catppuccin/tmux"
  mkdir -p "$HOME/.config/tmux/plugins/catppuccin"
  git clone -b v2.3.0 https://github.com/catppuccin/tmux.git "$HOME/.config/tmux/plugins/catppuccin/tmux"
else
  echo "  skip   catppuccin/tmux (already installed)"
fi

# tmux-weather
if [ ! -d "$HOME/.config/tmux/plugins/tmux-weather" ]; then
  echo "  install tmux-weather"
  git clone --depth=1 https://github.com/xamut/tmux-weather.git "$HOME/.config/tmux/plugins/tmux-weather"
else
  echo "  skip   tmux-weather (already installed)"
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
