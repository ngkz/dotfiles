# mauritius
## Overview
Windows 11 Enterprise + NixOS-WSL company laptop

## Installation
### Build system tarball on other NixOS machine:
``` sh
dotfiles$ sudo nix run .#nixosConfigurations.mauritius.config.system.build.tarballBuilder
```

### Transfer nixos-wsl.tar.gz

### Load into WSL2:
``` sh
wsl --install --no-distribution
wsl --import NixOS $env:USERPROFILE\NixOS\ Downloads\nixos-wsl.tar.gz
```

### Install secret keys
``` sh
wsl
sudo -e /etc/age.key
(age secret key)
sudo chmod 400 /etc/age.key
exit
wsl --shutdown
wsl
```
