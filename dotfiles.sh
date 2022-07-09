#! /bin/env bash

set -eux

git clone --depth 1 https://aur.archlinux.org/yay-bin.git
(cd yay-bin && makepkg -sic)
yay -S git zsh stow fzf fd htop-vim jq ripgrep tldr tmux tree pfetch lf-bin pandoc-bin

git clone https://github.com/FotiadisM/dotfiles.git ~/.dotfiles

# nvim
sudo pacman -S gcc
git clone --depth 1 https://github.com/wbthomason/packer.nvim.git ~/.local/share/nvim/site/pack/packer/start/packer.nvim

# lf
sudo pacman -S ffmpegthumbnailer imagemagick poppler gnome-epub-thumbnailer wkhtmltopdf bat chafa python-pip
python -m pip install ueberzug

# tmux
git clone https://github.com/tmux-plugins/tpm ~/.config/tmux/plugins/tpm

# zsh
export ZSH="${XDG_DATA_HOME:-$HOME/.local/share}/oh-my-zsh"
export ZSH_CUSTOM=$ZSH/custom
git clone --depth=1 https://github.com/ohmyzsh/ohmyzsh.git $ZSH
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git $ZSH_CUSTOM/themes/powerlevel10k
git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting.git $ZSH_CUSTOM/plugins/zsh-syntax-highlighting
git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions $ZSH_CUSTOM/plugins/zsh-autosuggestions
git clone --depth=1 https://github.com/endaaman/lxd-completion-zsh $ZSH_CUSTOM/plugins/lxd-completion-zsh
touch ~/.config/zsh/.zsh_history

# alacritty
fontsPath="$HOME/.local/share/fonts/ttf/DejaVuSansMono/"
mkdir -p $fontsPath
wget -P $fontsPath https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/DejaVuSansMono/Regular/complete/DejaVu%20Sans%20Mono%20Nerd%20Font%20Complete%20Mono.ttf
wget -P $fontsPath https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/DejaVuSansMono/Italic/complete/DejaVu%20Sans%20Mono%20Oblique%20Nerd%20Font%20Complete%20Mono.ttf
wget -P $fontsPath https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/DejaVuSansMono/Bold/complete/DejaVu%20Sans%20Mono%20Bold%20Nerd%20Font%20Complete%20Mono.ttf
wget -P $fontsPath https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/DejaVuSansMono/Bold-Italic/complete/DejaVu%20Sans%20Mono%20Bold%20Oblique%20Nerd%20Font%20Complete%20Mono.ttf
fc-cache

# stow
stow -d ~/.dotfiles/ -t ~/ base backgrounds scripts git zsh nvim lf tmux zathura alacritty

# CLEAN UP

rm ~/.bash* ~/.zsh* ~/.zcomp* ~/.lesshst
mv ~/.gnupg ~/.config/
