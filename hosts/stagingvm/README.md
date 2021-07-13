# stagingvm
## Overview
VirtualBox VM

## Set up filesystems
```sh
# Create partitions
parted /dev/sda -- mklabel gpt
parted /dev/sda -- mkpart ESP fat32 1MiB 512MiB
parted /dev/sda -- set 1 esp on
parted /dev/sda -- mkpart primary 512MiB 100%

# Format EFI System Partition
mkfs.fat -n ESP -F32 /dev/sda1

# Format LUKS partition
# GRUB supported luks2 recently, but grub-install on LUKS2 partition doesn't work yet.
# Also, it doesn't support argon2i KDF yet.
cryptsetup luksFormat --type luks1 /dev/sda2

# Halve PBKDF iteration count
# GRUB's PBKDF implementation is a lot slower than Linux's, because GRUB operates
# under tighter memory constraints and doesn’t take advantage of all
# crypto-related CPU instructions.
# Reducing the iteration count would speed up initial unlock.
cryptsetup luksDump /dev/sda2
# ...
# Key Slot 0: ENABLED
#	Iterations:         	1869118
# ...
cryptsetup luksChangeKey --pbkdf-force-iterations 600000 /dev/sda2

# Open LUKS partition
cryptsetup open /dev/sda2 cryptlvm --allow-discards

# Create Encrypted LVM PV and system VG on LUKS partition
pvcreate /dev/mapper/cryptlvm
vgcreate system /dev/mapper/cryptlvm

# Create encrypted swap
lvcreate -L 1G system -n swap
mkswap -L swap /dev/system/swap

# Create encrypted /nix
lvcreate -l 100%FREE system -n nix
mkfs.xfs -L nix -m bigtime=1 /dev/system/nix
```

## Mount filesystems
```sh
# Mount tmpfs root
mount -t tmpfs -o size=2G,mode=755,nodev,nosuid,noexec none /mnt

# Create mountpoints
mkdir -p /mnt/{nix,etc,var/log}

# Mount /nix
mount /dev/system/nix /mnt/nix

# Create a directory for persistent directories
mkdir -p /mnt/nix/persist/{boot/efi,etc,var/log}

# Mount ESP
mount /dev/sda1 /mnt/nix/persist/boot/efi

# Bind mount persistent /var/log
mount --bind /mnt/{nix/persist,}/var/log

# Enable swap
swapon -d /dev/system/swap
```

## Add a second key for single password unlock
```sh
mkdir -p /mnt/nix/persist/secrets
dd if=/dev/random of=/mnt/nix/persist/secrets/cryptlvm.key bs=4096 count=1
chmod 400 /mnt/nix/persist/secrets/cryptlvm.key
cryptsetup luksAddKey /dev/sda2 /mnt/nix/persist/secrets/cryptlvm.key
```
