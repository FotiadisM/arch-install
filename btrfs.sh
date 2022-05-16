#! /bin/env bash

set -eux

user="fotiadis"

pacman -S --noconfirm grub-btrfs snapper snap-pac rsync

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
sed -i "s/ALLOW_USERS=\"\"/ALLOW_USERS=\"$user\"/" /etc/snapper/configs/root
sed -i "s/ALLOW_GROUPS=\"\"/ALLOW_GROUPS=\"$user\"/" /etc/snapper/configs/root

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

systemctl enable grub-btrfs.path
