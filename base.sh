#! /bin/env bash

set -eux

dev="/dev/sda"
country="Greece"
zoneinfo="Europe/Athens"
hostname="transistor"
user="fotiadis"

timedatectl set-ntp true

sed -e 's/\s*\([\+0-9a-zA-Z]*\).*/\1/' <<EOF | fdisk $dev
g # create gpt table
n # new partition


+512M
t
1
n


+2G
t
2
19
n



w
EOF

mkfs.fat -F32 $dev"1"
mkswap $dev"2"
swapon $dev"2"
mkfs.btrfs $dev"3"

mount $dev"3" /mnt
btrfs su cr /mnt/@
btrfs su cr /mnt/@home
btrfs su cr /mnt/@tmp
btrfs su cr /mnt/@log
btrfs su cr /mnt/@cache
btrfs su cr /mnt/@srv
btrfs su cr /mnt/@root
btrfs su cr /mnt/@opt
btrfs su cr /mnt/@local
btrfs su cr /mnt/@snapshots

umount /mnt

mount $dev"3" -o noatime,compress=zstd,discard=async,space_cache=v2,ssd_spread,subvol=@ /mnt
mkdir -p /mnt/{boot,home,tmp,var/log,var/cache,srv,root,opt,usr/local,.snapshots}
mount $dev"3" -o noatime,compress=zstd,discard=async,space_cache=v2,ssd_spread,subvol=@home /mnt/home
mount $dev"3" -o noatime,compress=zstd,discard=async,space_cache=v2,ssd_spread,subvol=@tmp /mnt/tmp
mount $dev"3" -o noatime,compress=zstd,discard=async,space_cache=v2,ssd_spread,subvol=@log /mnt/var/log
mount $dev"3" -o noatime,compress=zstd,discard=async,space_cache=v2,ssd_spread,subvol=@cache /mnt/var/cache
mount $dev"3" -o noatime,compress=zstd,discard=async,space_cache=v2,ssd_spread,subvol=@srv /mnt/srv
mount $dev"3" -o noatime,compress=zstd,discard=async,space_cache=v2,ssd_spread,subvol=@root /mnt/root
mount $dev"3" -o noatime,compress=zstd,discard=async,space_cache=v2,ssd_spread,subvol=@opt /mnt/opt
mount $dev"3" -o noatime,compress=zstd,discard=async,space_cache=v2,ssd_spread,subvol=@local /mnt/usr/local
mount $dev"3" -o noatime,compress=zstd,discard=async,space_cache=v2,ssd_spread,subvol=@snapshots /mnt/.snapshots
mount $dev"1" /mnt/boot

reflector --country $country --protocol https --latest 5 --sort rate --save /etc/pacman.d/mirrorlist
sed -i 's/^#ParallelDownloads = 5/ParallelDownloads = 10/' /etc/pacman.conf

pacstrap /mnt base linux linux-firmware linux-headers btrfs-progs intel-ucode neovim
genfstab -U /mnt >> /mnt/etc/fstab
sed -i 's/subvolid=[0-9]*//g' /mnt/etc/fstab

ln -sf /usr/share/zoneinfo/$zoneinfo /etc/localtime
hwclock --systohc
sed -i 's/^# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen
locale-gen
echo 'LANG=en_US.UTF-8' >> /etc/locale.conf
echo $hostname >> /etc/hostname
cat >> /etc/hosts << EOF
127.0.0.1        localhost
::1              localhost
EOF

# NOTE: maybe edit /etc/mkinitcpio.conf ?

sed -i 's/^#Color/Color/' /etc/pacman.conf
sed -i 's/^#ParallelDownloads = 5/ParallelDownloads = 10/' /etc/pacman.conf

# possible icnlude nfs-utils inetutils
pacman -S --noconfirm \
	base-devel \
	grub grub-btrfs efibootmgr mtools dosfstools \
	networkmanager network-manager-applet wpa_supplicant \
	bluez bluez-utils cups \
	alsa-utils pipewire pipewire-alsa pipewire-jack pipewire-pulse pipewire-media-session \
	xdg-utils xdg-user-dirs \
	reflector

# TODO: enable experimental features for bluetooth, for battery percentage
# check https://wiki.archlinux.org/title/Bluetooth_headset#Battery_level_reporting

grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB
grub-mkconfig -o /boot/grub/grub.cfg

systemctl enable grub-btrfs.path
systemctl enable NetworkManager
systemctl enable bluetooth.service
systemctl enable cups.service
systemctl enable reflector.timer
systemctl enable fstrim.timer

sed -i 's/^# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' /etc/sudoers
useradd -mG wheel $user
echo $user":1234" | chpasswd

# needed for btrfs /tmp subvolume
cat > /etc/tmpfiles.d/tmp.conf << EOF
# Cleaning up /tmp everytime system boots
D! /tmp 1777 root root 0
EOF

# snapper
pacman -S snapper
umount /.snapshots
rm -r /.snapshots
snapper -c root create-config /
btrfs subvolume delete /.snapshots
mkdir /.snapshots
mount -a
chmod a+rx /.snapshots
chown :users /.snapshots
# TODO: add user to ALLOW_USERS in /etc/snapper/configs/root
mkdir /etc/pacman.d/hooks/
cat > etc/pacman.d/hooks/95-bootbackup.hook << EOF
[Trigger]
Operation = Upgrade
Operation = Install
Operation = Remove
Type = Path
Target = usr/lib/modules/*/vmlinuz

[Action]
Depends = rsync
Description = Backing up /boot...
When = PostTransaction
Exec = /usr/bin/rsync -a --delete /boot /.bootbackup
EOF
# TODO: enable snapper systemctl services

# TERM
pacman -S --noconfirm man-db man-pages git zsh fzf bat fd htop jq neofetch ripgrep tldr tmux tree
git clone https://aur.archlinux.org/yay.git
(cd yay && makepkg -sic)
rm -rf yay
yay -S pfetch lf

# dev
pacman -S --noconfirm go nodejs npm yarn kubectl helm terraform github-cli hugo

# pacman -S tuned

# GUI 

#gnome
pacman -S --noconfirm gnome gnome-tweaks gnome-software-packagekit-plugin xclip dconf-editor 
pacman -Rsn gnome-boxes epiphany
yay -S --noconfirm extension-manager
systemctl enable gdm.service

#qemu
pacman -S --noconfirm qemu qemu-arch-extra libvirt edk2-ovmf iptables-nft dnsmasq dmidecode bridge-utils openbsd-netcat virt-manager
# TODO: additional config required, https://wiki.archlinux.org/title/Virt-Manager
systemctl enable libvirtd.service

# general
pacman -S --noconfirm allacritty discord kdeconnect obs-studio signal-desktop vlc zathura zathura-pdf-mupdf zathura-djvu xournalpp transmission-gtk

# yay
yay -S --noconfirm brave-bin popcorntime-bin spotify-adblock

git clone --bare git@github.com:FotiadisM/dotfiles.git /home/$user/.dotfiles
git --git-dir=/home/$user/.dotfiles/ --work-tree=/home/$user/ checkout -f
