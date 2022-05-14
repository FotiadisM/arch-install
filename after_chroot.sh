#! /bin/env bash

set -eux

country="Greece"
zoneinfo="Europe/Athens"
hostname="transistor"
user="fotiadis"

ln -sf /usr/share/zoneinfo/$zoneinfo /etc/localtime
hwclock --systohc
sed -i 's/^#en_US.UTF-8/en_US.UTF-8/' /etc/locale.gen
locale-gen
echo 'LANG=en_US.UTF-8' >> /etc/locale.conf
echo $hostname >> /etc/hostname
cat >> /etc/hosts << EOF
127.0.0.1        localhost
::1              localhost
EOF

sed -i 's/^#Color/Color/' /etc/pacman.conf
sed -i 's/^#ParallelDownloads = 5/ParallelDownloads = 10/' /etc/pacman.conf

pacman -S --noconfirm \
	base-devel \
	grub efibootmgr mtools dosfstools \
	networkmanager network-manager-applet wpa_supplicant \
	bluez bluez-utils cups acpid \
	alsa-utils pipewire pipewire-alsa pipewire-jack pipewire-pulse wireplumber \
	xdg-utils xdg-user-dirs \
	reflector

# TODO: enable experimental features for bluetooth, for battery percentage
# check https://wiki.archlinux.org/title/Bluetooth_headset#Battery_level_reporting

grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB
grub-mkconfig -o /boot/grub/grub.cfg

# TODO: change reflector config

systemctl enable NetworkManager reflector.timer fstrim.timer bluetooth.service cups.service acpid.service

sed -i 's/^# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' /etc/sudoers
useradd -mG wheel $user
echo $user":1234" | chpasswd

