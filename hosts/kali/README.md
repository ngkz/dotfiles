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
rm (extended partition)
resizepart 1 -1GiB
p
mkpart linux-swap (/ END) 0
quit
sudo mkswap /dev/sda2
sudo swapon /dev/sda2
sudo -e /etc/fstab
(change swap UUID)
```

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

