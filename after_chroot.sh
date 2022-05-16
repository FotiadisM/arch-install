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

grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB
grub-mkconfig -o /boot/grub/grub.cfg

sed -i "s/^# --country France,Germany/--country $country/" /etc/xdg/reflector/reflector.conf
sed -i "s/^--sort age/--sort rate/" /etc/xdg/reflector/reflector.conf

# enable experimental features for bluetooth, for battery percentage
sed -i "s/^#Experimental = false/Experimental = true/" /etc/bluetooth/main.conf

systemctl enable NetworkManager reflector.timer fstrim.timer bluetooth.service cups.service acpid.service

sed -i 's/^# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' /etc/sudoers
useradd -mG wheel $user
echo $user":1234" | chpasswd
