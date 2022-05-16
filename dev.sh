#! /bin/env bash

set -ux

user="fotiadis"

export NPM_CONFIG_CACHE="${XDG_CACHE_HOME:-$HOME/.cache}/npm"
export NPM_CONFIG_PREFIX="${XDG_DATA_HOME:-$HOME/.local/share/}/npm"
sudo pacman -S curl wget man-db man-pages gcc nodejs npm yarn python-pip kubectl helm github-cli hugo

# rust
export RUSTUP_HOME="${XDG_DATA_HOME:-$HOME/.local/share/}/rustup"
export CARGO_HOME="${XDG_DATA_HOME:-$HOME/.local/share/}/cargo"
curl https://sh.rustup.rs -sSf | sh

# go
export GOPATH="${XDG_DATA_HOME:-$HOME/.local/share}/go"
go_version=$(wget --no-check-certificate -qO- https://golang.org/dl | grep -oP "go([0-9\.]+)\.linux-amd64\.tar\.gz" | head -n 1)
wget https://go.dev/dl/$go_version -O /tmp/$go_version
sudo rm -rf /usr/local/go && sudo tar -C /usr/local -xzf /tmp/$go_version

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
