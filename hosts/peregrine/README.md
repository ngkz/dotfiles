# peregrine
## Overview
ThinkPad E490. It's my main driver.

## Specs
Core i7-8565U, 16GB RAM, JIS keyboard, No dGPU, No fingerprint reader, Intel Wireless-AC 9260, WD SN550 1TB NVMe SSD, No HDD, Low Power LCD Mod(N140HCG-GQ2), Cooling Mod

Peripherals: ThinkPad USB-C Dock Gen 2, ThinkPad Compact USB Keyboard with TrackPoint(JIS), 2x 4K monitors, Amp and stereo speakers, 1x FHD monitor via FL2000 adapter(TODO)

## Installation
### Setup Secure boot
#### Backup stock keys
- Do once
```sh
nix shell nixpkgs#efitools
efi-readvar -v PK -o old_PK.esl
efi-readvar -v KEK -o old_KEK.esl
efi-readvar -v db -o old_db.esl
efi-readvar -v dbx -o old_dbx.esl
```

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

    1. Enter firmware setup
    2. `Security`
    3. `Secure Boot`
    4. Enable `Secure Boot`
    5. `Reset to Setup Mode`
    6. `Platform Mode` should be `Setup Mode` and `Secure Boot Mode` should be `Custom Mode` now.

2. Enroll keys
- Replaces default manufacturer/microsoft keys with custom personal key.
- **This might brick some machines!** Some devices need a microsoft-signed firmware to operate.

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
```
nvme0n1           259:0    0 931.5G  0 disk  
├─nvme0n1p1       259:1    0   511M  0 part  /boot
└─nvme0n1p2       259:2    0   867G  0 part  
  └─cryptlvm      254:0    0   867G  0 crypt 
    ├─system-swap 254:1    0    16G  0 lvm   [SWAP]
    └─system-nix  254:2    0   819G  0 lvm   /nix/store
                                             /var/log
                                             /nix
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
cryptsetup luksFormat /dev/nvme0n1p2

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
mkfs.xfs -L nix /dev/system/nix
```

## Mount filesystems
```sh
# Mount tmpfs root
mount -t tmpfs -o size=2G,mode=755 none /mnt

# Create mountpoints
mkdir -p /mnt/{boot,nix,var/log}

# Mount /nix
mount /dev/system/nix /mnt/nix

# Create a directory for persistent directories
mkdir -p /mnt/nix/persist/var/log

# Mount ESP
mount /dev/nvme0n1p1 /mnt/boot

# Bind mount persistent /var/log
mount --bind /mnt/{nix/persist,}/var/log

# Enable swap
swapon -d /dev/system/swap
```

### Install secret keys
```sh
mkdir /mnt/nix/persist/secrets

cat <<'EOS' >/mnt/nix/persist/secrets/age.key
(age secret key)
EOS

cat <<'EOS' >/mnt/nix/persist/secrets/db.crt
(secure boot signature database certificate)
EOS

cat <<'EOS' >/mnt/nix/persist/secrets/db.key
(secure boot signature database key)
EOS

chmod 400 /mnt/nix/persist/secrets/*
```

### Install NixOS
```sh
nix-shell -p git nixFlakes
git clone https://github.com/ngkz/dotfiles
cd dotfiles
vim hosts/peregrine/default.nix
(Update filesystems UUIDs)
nixos-install --root /mnt --flake ".#peregrine" --no-root-passwd --impure
```

### Re-enable Secure Boot
