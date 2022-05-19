#! /bin/env bash

set -eux

git clone --depth 1 https://aur.archlinux.org/yay-bin.git
(cd yay-bin && makepkg -sic)
yay -S git zsh stow fzf fd htop-vim jq ripgrep tldr tmux tree pfetch lf-bin pandoc-bin

# stow
git clone https://github.com/FotiadisM/dotfiles.git ~/.dotfiles
stow -d ~/.dotfiles/ -t ~/ base backgrounds scripts git zsh nvim lf tmux zathura alacritty

# nvim
sudo pacman -S gcc
git clone --depth 1 https://github.com/wbthomason/packer.nvim.git ~/.local/share/nvim/site/pack/packer/start/packer.nvim

# lf
sudo pacman -S ffmpegthumbnailer imagemagick poppler gnome-epub-thumbnailer wkhtmltopdf bat chafa python-pip
pip install ueberzug

# tmux
git clone https://github.com/tmux-plugins/tpm ~/.config/tmux/plugins/tpm

# zsh
export ZSH="${XDG_DATA_HOME:-$HOME/.local/share}/oh-my-zsh"
export ZSH_CUSTOM=$ZSH/custom
git clone --depth=1 https://github.com/ohmyzsh/ohmyzsh.git $ZSH
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git $ZSH_CUSTOM/themes/powerlevel10k
git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting.git $ZSH_CUSTOM/plugins/zsh-syntax-highlighting
git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions $ZSH_CUSTOM/plugins/zsh-autosuggestions
git clone --depth=1 https://github.com/zsh-users/zsh-completions $ZSH_CUSTOM/plugins/zsh-completions
touch ~/.config/zsh/.zsh_history

# CLEAN UP

rm ~/.bash* ~/.zsh* ~/.zcomp* ~/.lesshst
mv ~/.gnupg ~/.config/
