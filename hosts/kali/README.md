# kali

## Overview

Kali Linux rolling + home-manager Vagrant VM

## Usage

### Create and/or start

```sh
VAGRANT_EXPERIMENTAL="disks" vagrant up --provision
```

Resize / partition with:
```sh
vagrant ssh
sudo swapoff /dev/sda5
sudo parted /dev/sda
p
rm 2
resizepart 1 -2GiB
p
mkpart
Partition type?  primary/extended? primary
File system type?  [ext2]? linux-swap
Start? -2GiB
End? -0
quit
sudo mkswap /dev/sda2
sudo swapon /dev/sda2
sudo -e /etc/fstab
(change swap UUID)
sudo resize2fs /dev/sda1
```

Enabling extended session mode:
https://www.kali.org/docs/virtualization/install-hyper-v-guest-enhanced-session-mode/

### Switch the configuration

```sh
vagrant provision
```

### SSH

``` sh
vagrant ssh
```

### Stop

``` sh
vagrant halt
```

### Snapshot

``` sh
vagrant snapshot save NAME
vagrant snapshot restore NAME
OR
vagrant snapshot push
vagrant snapshot pop

vagrant snapshot list
vagrant snapshot delete NAME
```

### Destroy

``` sh
vagrant destroy
```

