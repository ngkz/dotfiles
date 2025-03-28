# mauritius
## Overview
VMWare VM

 * Other Linux 6.x kernel 64bit
 * 16G RAM
 * 11 cores
 * 300GB SCSI disk
 * NAT network
 * USB 3.1
 * BIOS
 * Virtualize VT or AMD-V
 * 3D graphics acceleration

## Installation
### Boot with NixOS ISO
- Boot a NixOS installer ISO

### Load keyboard layout
```sh
loadkeys jp106
```

### Set up filesystems
```sh
# Create partitions
parted /dev/sda -- mklabel msdos
parted /dev/sda -- mkpart primary 1MiB 100%
parted /dev/sda -- set 1 boot on

# Format the persistent data container
mkfs.btrfs -L root /dev/sda1

# mount root subvolume and create subvolumes
mount /dev/sda1 /mnt
btrfs subvolume create /mnt/boot
btrfs subvolume create /mnt/nix
btrfs subvolume create /mnt/persist
btrfs subvolume create /mnt/persist/home
btrfs subvolume create /mnt/swap
btrfs subvolume create /mnt/snapshots

# Create directories for persistent storage
mkdir -p /mnt/persist/var/log

# Create swapfile
btrfs filesystem mkswapfile --size 8G /mnt/swap/swapfile

umount /mnt
```

## Mount filesystems
```sh
# Mount tmpfs root
mount -t tmpfs -o size=2G,mode=755 none /mnt

# Create mountpoints
mkdir -p /mnt/{boot,nix,var/{log,persist,swap}}

# Mount persistent storages
mount -o compress=zstd:1,lazytime,subvol=boot /dev/sda1 /mnt/boot
mount -o compress=zstd:1,lazytime,subvol=nix /dev/sda1 /mnt/nix
mount -o compress=zstd:1,lazytime,subvol=persist /dev/sda1 /mnt/var/persist
mount -o compress=zstd:1,lazytime,subvol=swap /dev/sda1 /mnt/var/swap

# Bind mount persistent /var/log
mount --bind /mnt/{var/persist,}/var/log

# Enable swap
swapon /mnt/var/swap/swapfile
```

### Install secret keys
```sh
mkdir /mnt/var/persist/secrets

cat <<'EOS' >/mnt/var/persist/secrets/age.key
(age secret key)
EOS

chmod 400 /mnt/var/persist/secrets/*
```

### Update hardware configuration
 * use `nixos-generate-config --root /mnt` to generate hardware config

### Install NixOS
```sh
passwd
(set password)
(transfer dotfiles with `rsync -a dotfiles nixos@<IP>:~/`)
cd dotfiles
nixos-install --root /mnt --flake ".#mauritius" --no-root-passwd --option substituters http://peregrine.v.f2l.cc:5000 --option trusted-public-keys "peregrine:ttyus2jSLVWOMNfGkwgC71iJ36DZgJINICtkdUMeg8k="
```
