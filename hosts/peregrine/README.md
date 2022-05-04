# peregrine
## Overview
ThinkPad E490. It's my main driver.

## Specs
Core i7-8565U, 16GB RAM, JIS keyboard, No dGPU, No fingerprint reader, Intel Wireless-AC 9260, WD SN550 1TB NVMe SSD, No HDD, Low Power LCD Mod(N140HCG-GQ2), Cooling Mod

Peripherals: ThinkPad USB-C Dock Gen 2, ThinkPad Compact USB Keyboard with TrackPoint(JIS), 2x 4K monitors, 1x FHD monitor via FL2000 adapter, Speakers

## Set up filesystems
```
nvme0n1           259:0    0 931.5G  0 disk  
├─nvme0n1p2       259:1    0   867G  0 part  
│ └─cryptlvm      254:0    0   867G  0 crypt 
│   ├─system-swap 254:1    0    16G  0 lvm   [SWAP]
│   └─system-nix  254:2    0   819G  0 lvm   /var/log
│                                            /nix
└─nvme0n1p1       259:2    0   511M  0 part  /nix/persist/boot/efi
```

- 512MB vfat ESP /boot
- Encrypted LVM PV:
  - LVM VG system:
    - 16G swap
    - xfs /
    - 32G free space for lvm snapshot
- 64GB free space for windoze (for firmware update)

```sh
# Create partitions
parted /dev/nvme0n1 -- mklabel gpt
parted /dev/nvme0n1 -- mkpart ESP fat32 1MiB 512MiB
parted /dev/nvme0n1 -- set 1 esp on
parted /dev/nvme0n1 -- mkpart primary 512MiB -64GiB

# Format EFI System Partition
mkfs.fat -n ESP -F32 /dev/nvme0n1p1

# Format LUKS partition
# GRUB supported luks2 recently, but grub-install on LUKS2 partition doesn't work yet.
# Also, it doesn't support argon2i KDF yet.
cryptsetup luksFormat --type luks1 /dev/nvme0n1p2

# Halve PBKDF iteration count
# GRUB's PBKDF implementation is a lot slower than Linux's, because GRUB operates
# under tighter memory constraints and doesn’t take advantage of all
# crypto-related CPU instructions.
# Reducing the iteration count would speed up initial unlock.
cryptsetup luksDump /dev/nvme0n1p2
# ...
# Key Slot 0: ENABLED
#	Iterations:         	2394008
# ...
cryptsetup luksChangeKey --key-slot 0 --pbkdf-force-iterations 1197004 /dev/nvme0n1p2

# Open LUKS partition
cryptsetup open /dev/nvme0n1p2 cryptlvm --allow-discards

# Create Encrypted LVM PV and system VG on LUKS partition
pvcreate /dev/mapper/cryptlvm
vgcreate system /dev/mapper/cryptlvm

# Create encrypted swap
lvcreate -L 16G system -n swap
mkswap -L swap /dev/system/swap

# Create encrypted /nix
lvcreate -L 819G system -n nix
mkfs.xfs -L nix -m bigtime=1 /dev/system/nix
```

## Mount filesystems
```sh
# Mount tmpfs root
mount -t tmpfs -o size=2G,mode=755 /mnt

# Create mountpoints
mkdir -p /mnt/{nix,etc,var/log}

# Mount /nix
mount /dev/system/nix /mnt/nix

# Create a directory for persistent directories
mkdir -p /mnt/nix/persist/{boot/efi,etc,var/log}

# Mount ESP
mount /dev/nvme0n1p1 /mnt/nix/persist/boot/efi

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
cryptsetup luksAddKey /dev/nvme0n1p2 /mnt/nix/persist/secrets/cryptlvm.key
```
