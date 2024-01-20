# kali

## Overview

Kali Linux rolling + home-manager Vagrant VM

## Usage

### Create and/or start

```sh
VAGRANT_EXPERIMENTAL="disks" vagrant up --provision
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

