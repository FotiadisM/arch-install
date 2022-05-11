#! /bin/env bash

set -eux

pacman -S --noconfirm grub-btrfs snapper

# needed for btrfs /tmp subvolume
cat > /etc/tmpfiles.d/tmp.conf << EOF
# Cleaning up /tmp everytime system boots
D! /tmp 1777 root root 0
EOF

# snapper
umount /.snapshots
rm -r /.snapshots
snapper -c root create-config /
btrfs subvolume delete /.snapshots
mkdir /.snapshots
mount -a
chmod 755 /.snapshots
chown :users /.snapshots
# TODO: add user to ALLOW_USERS in /etc/snapper/configs/root

# include /boot in the backup
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

# TODO: edit snapper root config and enable snapper systemctl services
systemctl enable grub-btrfs.path
