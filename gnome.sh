#! /bin/env bash

set -eux

# gnome
pacman -S --noconfirm gnome gnome-tweaks gnome-software-packagekit-plugin gst-libav xclip dconf-editor power-profiles-daemon
pacman -Rsn gnome-boxes epiphany
yay -S extension-manager kora-icon-theme skeuos-gtk
systemctl enable gdm.service power-profiles-daemon.service

dconf load / < $1

# general
pacman -S --noconfirm allacritty discord signal-desktop zathura zathura-pdf-mupdf xournalpp fragments libreoffice-fresh

# yay
yay -S brave-bin popcorntime-bin spotify-adblock
