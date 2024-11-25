# flarevm

## Overview

Vagrant [FLARE-VM](https://github.com/mandiant/flare-vm)

## Usage

### Create and start

1. Start and provision

   ```sh
   vagrant up --provision
   ```

2. Disable Windows Defender
   https://lazyadmin.nl/win-11/turn-off-windows-defender-windows-11-permanently/

   1. Restart with safe mode
      reboot with shift pressed down
   2. win+r powershell and run this script
      ```powershell
       # Disable Windows Defender
       $servicepath = 'HKLM:\\SYSTEM\\CurrentControlSet\\Services'
       $targets = @('Sense', 'WdBoot', 'WdFilter', 'WdNisDrv', 'WdNisSvc', 'WinDefend', 'MDCoreSvc')

       foreach ($target in $targets) {
         Set-ItemProperty "$servicepath\\$target" Start -Value 4 -type Dword
       }
       ```

3. Setup Flare VM

   ```powershell
   cd $env:TEMP
   Invoke-WebRequest -Uri "https://raw.githubusercontent.com/fireeye/flare-vm/master/install.ps1" -OutFile install.ps1
   Unblock-File .\\install.ps1
   Set-ExecutionPolicy Unrestricted -Force
   .\\install.ps1 -password vagrant -noWait -noChecks
   ```

4. Enable auto logon

   ```powershell
    # Auto logon
    $RegistryPath = 'HKLM:\\SOFTWARE\\Microsoft\\Windows NT\\CurrentVersion\\Winlogon'
    Set-ItemProperty $RegistryPath 'DefaultUsername' -Value "vagrant" -type String
    Set-ItemProperty $RegistryPath 'DefaultPassword' -Value "vagrant" -type String
    Set-ItemProperty $RegistryPath 'AutoAdminLogon' -Value "1" -Type String
    ```

5. Take clean snapshot

   ```sh
   vagrant snapshot save clean
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
