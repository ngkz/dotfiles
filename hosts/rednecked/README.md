# rednecked
## Overview
Homeserver

## Specs
AMD Athlon 200GE, BIOSTAR A320MH, 4GB RAM, Transcend TG512GSSD370S 512GB SATA SSD, Seagate ST8000DM004 SMR 8TB HDD, WYI350-T4 4-ports GbE NIC, AR9287 2x2 11bgn WiFi, QCA6391 2x2 11ax WiFi

## Installation
### Boot with NixOS ISO
- Boot a NixOS installer ISO

### Load keyboard layout
```sh
loadkeys jp106
```

### Set up filesystems
```sh
# TRIM the whole disk
blkdiscard -f /dev/sda

# Create partitions
parted /dev/sda -- mklabel gpt
parted /dev/sda -- mkpart ESP fat32 1MiB 512MiB
parted /dev/sda -- set 1 esp on
parted /dev/sda -- mkpart NixOS 512MiB 50%
parted /dev/sda -- mkpart spinningrust-cache 50% 100%

parted /dev/sdb -- mklabel gpt
parted /dev/sdb -- mkpart spinningrust-back 1MiB 100%

# Format EFI System Partition
mkfs.fat -n ESP -F32 /dev/sda1

# Format the persistent data container
mkfs.btrfs -L NixOS /dev/sda2

# mount root subvolume and create subvolumes
mount /dev/sda2 /mnt
btrfs subvolume create /mnt/nix
btrfs subvolume create /mnt/persist
btrfs subvolume create /mnt/swap
btrfs subvolume create /mnt/snapshots

# Create directories for persistent storage
mkdir -p /mnt/persist/var/log

# Create swapfile
btrfs filesystem mkswapfile --size 6G /mnt/swap/swapfile

umount /mnt

# Initialize bcached storage
wipefs -a /dev/sdb1
make-bcache -B /dev/sdb1 -C /dev/sda3 --writeback
mkfs.btrfs -L spinningrust /dev/bcache0
```

## Mount filesystems
```sh
# Mount tmpfs root
mount -t tmpfs -o size=2G,mode=755 none /mnt

# Create mountpoints
mkdir -p /mnt/{boot,nix,var/{log,persist,swap}}

# Mount ESP
mount /dev/sda1 /mnt/boot

# Mount persistent storages
mount -o lazytime,subvol=nix /dev/sda2 /mnt/nix
mount -o lazytime,subvol=persist /dev/sda2 /mnt/var/persist
mount -o lazytime,subvol=swap /dev/sda2 /mnt/var/swap

# Bind mount persistent /var/log
mount --bind /mnt/{var/persist,}/var/log

# Enable swap
swapon /mnt/var/swap/swapfile
```

### Install secret keys
```sh
mkdir /mnt/var/persist/secrets

cat <<'EOS' >/mnt/var/persist/secrets/age.key
(server age secret key)
EOS

chmod 400 /mnt/var/persist/secrets/*
```

### Install NixOS
```sh
nix-shell -p git nixFlakes
git clone https://github.com/ngkz/dotfiles
cd dotfiles
vim hosts/rednecked/default.nix
(Update filesystems UUIDs)
nixos-install --root /mnt --flake ".#rednecked" --no-root-passwd --impure
```
