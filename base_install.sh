#! /bin/env bash

set -eux

dev="/dev/sda"
country="Greece"

timedatectl set-ntp true

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
btrfs su cr /mnt/@flatpak
btrfs su cr /mnt/@libvirt
btrfs su cr /mnt/@srv
btrfs su cr /mnt/@root
btrfs su cr /mnt/@opt
btrfs su cr /mnt/@local
btrfs su cr /mnt/@snapshots

umount /mnt

mount $dev"3" -o noatime,compress=zstd,discard=async,space_cache=v2,ssd_spread,subvol=@ /mnt

mkdir -p /mnt/{boot,home,tmp,var/log,var/cache,var/lib/flatpak,var/lib/libvirt,srv,root,opt,usr/local,.snapshots}
chattr +C /var/lib/libvirt

mount $dev"3" -o noatime,compress=zstd,discard=async,space_cache=v2,ssd_spread,subvol=@home /mnt/home
mount $dev"3" -o noatime,compress=zstd,discard=async,space_cache=v2,ssd_spread,subvol=@tmp /mnt/tmp
mount $dev"3" -o noatime,compress=zstd,discard=async,space_cache=v2,ssd_spread,subvol=@log /mnt/var/log
mount $dev"3" -o noatime,compress=zstd,discard=async,space_cache=v2,ssd_spread,subvol=@cache /mnt/var/cache
mount $dev"3" -o noatime,compress=zstd,discard=async,space_cache=v2,ssd_spread,subvol=@flatpak /mnt/var/lib/flatpak
mount $dev"3" -o noatime,compress=zstd,discard=async,space_cache=v2,ssd_spread,subvol=@flatpak /mnt/var/lib/libvirt
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
