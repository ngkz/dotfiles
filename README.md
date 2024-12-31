# My NixOS configuration

[![NixOS 24.11](https://img.shields.io/badge/NixOS-v24.11-blue.svg?style=flat-square&logo=NixOS&logoColor=white)](https://nixos.org)

## Installation

See `hosts/<HOSTNAME>/README.md`.

## Development shell

```sh
nix develop
OR
direnv allow
```

## Open a shell with specific packages available

```sh
nix shell "<flake>#<package>"
```

## Locate the package providing a certain file

```sh
nix-locate "<file>"
```

## Acknowledgements

- [Nix command/flake](https://nixos.wiki/wiki/Nix_command/flake)
- [Nix Flakes, Part 3: Managing NixOS systems](https://www.tweag.io/blog/2020-07-31-nixos-flakes/)
- [hlissner/dotfiles](https://github.com/hlissner/dotfiles)
- [pinpox/nixos](https://github.com/pinpox/nixos)
- [gytis-ivaskevicius/flake-utils-plus](https://github.com/gytis-ivaskevicius/flake-utils-plus)
- [berbiche/dotfiles](https://github.com/berbiche/dotfiles)
- [jpas/etc-nixos](https://github.com/jpas/etc-nixos)
- [pimeys/nixos](https://github.com/pimeys/nixos/commit/9c4306ceac36b7f69fd2ea5e2345200d7336be20)
- [leanprover/lean4](https://github.com/leanprover/lean4/blob/master/nix/packages.nix)
- [erpalma/throttled](https://github.com/erpalma/throttled)
- [mihic/linux-intel-undervolt](https://github.com/mihic/linux-intel-undervolt)
- [swaywm/sway](https://github.com/swaywm/sway)
- [Melkor333/milkOS](https://github.com/Melkor333/milkOS)
- Secure Boot
  - [Secure Boot - ArchWiki](https://wiki.archlinux.org/title/Unified_Extensible_Firmware_Interface/Secure_Boot#Using_your_own_keys)
  - [Sakaki's EFI Install Guide/Configuring Secure Boot under OpenRC](https://wiki.gentoo.org/wiki/User:Sakaki/Sakaki%27s_EFI_Install_Guide/Configuring_Secure_Boot_under_OpenRC)
  - [Secure Boot with GRUB 2 and signed Linux images and initrds](https://ruderich.org/simon/notes/secure-boot-with-grub-and-signed-linux-and-initrd)
- tmpfs as root setup
  - [Erase your darlings: immutable infrastructure for mutable systems - Graham Christensen](https://grahamc.com/blog/erase-your-darlings)
  - [NixOS ❄: tmpfs as root](https://elis.nu/blog/2020/05/nixos-tmpfs-as-root/)
  - [Encrypted Btrfs Root with Opt-in State On NixOS](https://mt-caret.github.io/blog/posts/2020-06-29-optin-state.html)
- [BTRFS: Finding and fixing highly fragmented files](https://helmundwalter.de/blog/btrfs-finding-and-fixing-highly-fragmented-files/)
- [balsoft/nixos-fhs-compat](https://github.com/balsoft/nixos-fhs-compat)
- [Ricing up Org Mode](https://lepisma.xyz/2017/10/28/ricing-org-mode/)
