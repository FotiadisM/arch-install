#! /bin/env bash

set -ux

user="fotiadis"

export GOPATH="${XDG_DATA_HOME:-$HOME/.local/share}/go"
export RUSTUP_HOME="${XDG_DATA_HOME:-$HOME/.local/share/}/rustup"
export CARGO_HOME="${XDG_DATA_HOME:-$HOME/.local/share/}/cargo"
export NPM_CONFIG_CACHE="${XDG_CACHE_HOME:-$HOME/.cache}/npm"
export NPM_CONFIG_PREFIX="${XDG_DATA_HOME:-$HOME/.local/share/}/npm"


sudo pacman -S --noconfirm curl gcc nodejs npm yarn python-pip
curl https://sh.rustup.rs -sSf | sh
go_version=$(wget --no-check-certificate -qO- https://golang.org/dl | grep -oP "go([0-9\.]+)\.linux-amd64\.tar\.gz" | head -n 1)
wget https://go.dev/dl/$go_version -O /tmp/$go_version
sudo rm -rf /usr/local/go && sudo tar -C /usr/local -xzf /tmp/$go_version

sudo pacman -S --noconfirm man-db man-pages git zsh stow fzf fd htop jq ripgrep tldr tmux tree
git clone --depth 1 https://aur.archlinux.org/yay-bin.git
(cd yay-bin && makepkg -sic)
rm -rf yay-bin
yay -S pfetch

# DOTFILES

git clone https://github.com/FotiadisM/dotfiles.git ~/.dotfiles
stow -d ~/.dotfiles/ -t ~/ base git zsh nvim lf tmux zathura alacritty

# nvim
yay -S pandoc-bin
git clone --depth 1 https://github.com/wbthomason/packer.nvim.git ~/.local/share/nvim/site/pack/packer/start/packer.nvim

# lf
yay -S lf-bin
pip install ueberzug
pacman -S --noconfirm ffmpegthumbnailer imagemagick poppler gnome-epub-thumbnailer wkhtmltopdf bat chafa

# tmux
git clone https://github.com/tmux-plugins/tpm ~/.config/tmux/plugins/tpm

# zsh
export ZSH="${XDG_DATA_HOME:-$HOME/.local/share}/oh-my-zsh"
export ZSH_CUSTOM=$ZSH/custom
git clone --depth 1 https://github.com/ohmyzsh/ohmyzsh.git $ZSH
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git $ZSH_CUSTOM/themes/powerlevel10k
git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting.git $ZSH_CUSTOM/plugins/zsh-syntax-highlighting
git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions $ZSH_CUSTOM/plugins/zsh-autosuggestions
git clone --depth=1 https://github.com/zsh-users/zsh-completions $ZSH_CUSTOM/plugins/zsh-completions
touch ~/.config/zsh/.zsh_history

# DEV STUFF

pacman -S --noconfirm kubectl helm terraform github-cli hugo

# qemu
sudo pacman -S qemu-full libvirt edk2-ovmf iptables-nft dnsmasq dmidecode bridge-utils openbsd-netcat virt-manager
sed -i 's/^#unix_sock_group = "libvirt"/unix_sock_group = "libvirt"/' /etc/libvirt/libvirtd.conf
sed -i 's/^#unix_sock_ro_perms = "0777"/unix_sock_ro_perms = "0777"/' /etc/libvirt/libvirtd.conf
usermod -aG libvirt $user
# NOTE: update the sed commands underneath, only for hard drive access?
# sed -i "s/^#user = \"root\"/user = \"$user\"/" /etc/libvirt/qemu.conf
# sed -i "s/^#group = \"root\"/group = \"$user\"/" /etc/libvirt/qemu.conf
systemctl enable libvirtd.service

# docker
sudo pacman -S docker
usermod -aG docker $user
systemctl enable docker.service

# CLEAN UP

rm ~/.bash* ~/.zsh* ~/.zcomp* ~/.lesshst
mv ~/.gnupg ~/.config/
