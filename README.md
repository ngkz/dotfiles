# My NixOS configuration
[![NixOS 21.05](https://img.shields.io/badge/NixOS-v21.05-blue.svg?style=flat-square&logo=NixOS&logoColor=white)](https://nixos.org)

## Installation
1. Load keyboard layout
   `loadkeys jp106`
2. Set up and mount filesystems
   Set up FDE
   See `hosts/<HOSTNAME>/README.md`.
3. Install age secret key
   ```sh
   cat <<'EOS' >/mnt/nix/persist/secrets/age.key
   (age secret key)
   EOS
   chmod 400 /mnt/nix/persist/secrets/age.key
   ```
3. Install NixOS
   ```sh
   nix-shell -p git nixUnstable
   git clone https://github.com/ngkz/dotfiles
   cd dotfiles
   nixos-install --root /mnt --flake ".#<HOSTNAME>" --no-root-passwd
   ```

## Update system
```sh
cd <PATH TO DOTFILES>
# update all inputs in flake.nix
nix flake update
# build nixosConfigurations.<HOSTNAME> of ./flake.nix
sudo nixos-rebuild switch --flake ".#"
```

## Build system
```sh
nix build "<PATH TO DOTFILES>#nixosConfigurations.<HOSTNAME>.config.system.build.toplevel" [--rebuild]
```

## Apply configuration changes
```sh
# build nixosConfigurations.<HOSTNAME> of ./flake.nix
sudo nixos-rebuild switch --flake "<PATH TO DOTFILES>#"
```

## Garbage collection
```sh
# Delete old generations
sudo nix-env --delete-generations old --profile /nix/var/nix/profiles/system
# Perform garbage collection the store
nix store gc
# Replace identical files in the store by hard links
nix store optimise
# Update boot entries
sudo /nix/var/nix/profiles/system/bin/switch-to-configuration switch
```

## REPL
```sh
# Load configuration of current host
nix repl ./repl.nix
# Or, load configuration of the specified host
nix repl --argstr hostname stagingvm ./repl.nix
nix-repl> config.foo.bar
```

## Open a shell with specific packages available
```sh
nix shell "<flake>#<package>"
```

## Acknowledgements
- [Nix command/flake](https://nixos.wiki/wiki/Nix_command/flake)
- [Nix Flakes, Part 3: Managing NixOS systems](https://www.tweag.io/blog/2020-07-31-nixos-flakes/)
- [hlissner/dotfiles](https://github.com/hlissner/dotfiles)
- [pinpox/nixos](https://github.com/pinpox/nixos)
- [gytis-ivaskevicius/flake-utils-plus](https://github.com/gytis-ivaskevicius/flake-utils-plus)
- Full Disk Encryption Setup
   - [ladinu/encryptedNixos.md](https://gist.github.com/ladinu/bfebdd90a5afd45dec811296016b2a3f)
   - [Full disk encryption, including /boot: Unlocking LUKS devices from GRUB](https://cryptsetup-team.pages.debian.net/cryptsetup/encrypted-boot.html)
- tmpfs as root setup
   - [Erase your darlings: immutable infrastructure for mutable systems - Graham Christensen](https://grahamc.com/blog/erase-your-darlings)
   - [NixOS ❄: tmpfs as root](https://elis.nu/blog/2020/05/nixos-tmpfs-as-root/)
   - [Encrypted Btrfs Root with Opt-in State On NixOS](https://mt-caret.github.io/blog/posts/2020-06-29-optin-state.html)
