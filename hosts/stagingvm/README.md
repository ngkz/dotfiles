# stagingvm
## Overview
Hyper-V/QEMU VM

## Installation
### Setup secure boot
#### Create Secure Boot keys
- Do once
```sh
nix shell nixpkgs#openssl nixpkgs#efitools

uuidgen --random >GUID.txt

# Platform key
openssl req -newkey rsa:2048 -nodes -keyout PK.key -new -x509 -sha256 -days 3650 -subj "/CN=My Platform Key/" -out PK.crt
cert-to-efi-sig-list -g "$(< GUID.txt)" PK.crt PK.esl
sign-efi-sig-list -g "$(< GUID.txt)" -k PK.key -c PK.crt PK PK.esl PK.auth

# Key Exchange Key
openssl req -newkey rsa:2048 -nodes -keyout KEK.key -new -x509 -sha256 -days 3650 -subj "/CN=My Key Exchange Key/" -out KEK.crt
cert-to-efi-sig-list -g "$(< GUID.txt)" KEK.crt KEK.esl
sign-efi-sig-list -g "$(< GUID.txt)" -k PK.key -c PK.crt KEK KEK.esl KEK.auth

# Signature Database Key
openssl req -newkey rsa:2048 -nodes -keyout db.key -new -x509 -sha256 -days 3650 -subj "/CN=My Signature Database key/" -out db.crt
cert-to-efi-sig-list -g "$(< GUID.txt)" db.crt db.esl
sign-efi-sig-list -g "$(< GUID.txt)" -k KEK.key -c KEK.crt db db.esl db.auth

chmod 400 *.key
chown root:root *
```

#### Install secure boot keys
1. Put the firmware in Setup Mode
 - Hyper-V does not support custom secure boot keys

2. Install keys

    ```sh
    nix shell nixpkgs#efitools
    efi-updatevar -e -f old_dbx.esl dbx
    efi-updatevar -e -f db.esl db
    efi-updatevar -e -f KEK.esl KEK
    efi-updatevar -f PK.auth PK
    efi-readvar
    ```

    it should be:
    ```
    Variable PK, length 837
    PK: List 0, type X509
        Signature 0, size 809, owner (GUID)
            Subject:
                CN=My Platform Key
            Issuer:
                CN=My Platform Key
    Variable KEK, length 845
    KEK: List 0, type X509
        Signature 0, size 817, owner (GUID)
            Subject:
                CN=My Key Exchange Key
            Issuer:
                CN=My Key Exchange Key
    Variable db, length 857
    db: List 0, type X509
        Signature 0, size 829, owner (GUID)
            Subject:
                CN=My Signature Database key
            Issuer:
                CN=My Signature Database key
    Variable dbx, length 13396
    dbx: List 0, type SHA256
    ...
    Variable MokList has no entries
    ```

### Boot with NixOS ISO
- Disable Secure Boot and boot a NixOS installer ISO

### Load keyboard layout
```sh
loadkeys jp106
```

### Set up filesystems
```sh
# Create partitions
parted /dev/sda -- mklabel gpt
parted /dev/sda -- mkpart ESP fat32 1MiB 1GiB
parted /dev/sda -- set 1 esp on
parted /dev/sda -- mkpart NixOS 1GiB 100%

# Format EFI System Partition
mkfs.fat -n ESP -F32 /dev/sda1

# Create and open an encrypted persistent data container
cryptsetup luksFormat /dev/sda2
cryptsetup open /dev/sda2 cryptroot --allow-discards

# Format the persistent data container
mkfs.btrfs -L root /dev/mapper/cryptroot

# mount root subvolume and create subvolumes
mount /dev/mapper/cryptroot /mnt
btrfs subvolume create /mnt/nix
btrfs subvolume create /mnt/persist
btrfs subvolume create /mnt/persist/home
btrfs subvolume create /mnt/swap
btrfs subvolume create /mnt/snapshots

# Create directories for persistent storage
mkdir -p /mnt/persist/var/log

# Create swapfile
truncate -s 0 /mnt/swap/swapfile
chattr +C /mnt/swap/swapfile
fallocate -l 4G /mnt/swap/swapfile
chmod 0600 /mnt/swap/swapfile
mkswap /mnt/swap/swapfile

umount /mnt
```

<!-- XXX `use btrfs filesystem mkswapfile` after NixOS 23.05 upgrade -->

### Mount filesystems
```sh
# Mount tmpfs root
mount -t tmpfs -o size=2G,mode=755 none /mnt

# Create mountpoints
mkdir -p /mnt/{boot,nix,var/{log,persist,swap}

# Mount ESP
mount /dev/sda1 /mnt/boot

# Mount persistent storages
mount -o compress=zstd,subvol=nix /dev/mapper/cryptroot /mnt/nix
mount -o compress=zstd,subvol=persist /dev/mapper/cryptroot /mnt/var/persist
mount -o compress=zstd,subvol=swap /dev/mapper/cryptroot /mnt/var/swap

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

### Install NixOS
```sh
nix-shell -p git nixFlakes
git clone https://github.com/ngkz/dotfiles
cd dotfiles
nixos-install --root /mnt --flake ".#stagingvm" --no-root-passwd --impure
```

### Re-enable Secure Boot

### Configure hibernation
```sh
nix shell nixpkgs-unstable#btrfs-progs
btrfs inspect-internal map-swapfile /var/swap/swapfile
Physical start:   2186280960
Resume offset:        533760
nvim hosts/prairie/default.nix
```
```
boot.kernelParams = [ "resume_offset=533760" ];
```
```sh
switch
```
```
