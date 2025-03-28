# flarevm

## Overview

[FLARE-VM](https://github.com/mandiant/flare-vm)

## Setup

### Vagrant

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

### VMWare

1. Download Windows 11 IoT Enterprise LTSC ISO
   https://www.microsoft.com/en-us/evalcenter/download-windows-11-iot-enterprise-ltsc-eval

2. Create VM
    * Windows 11 x64
    * 4 cores
    * 8GB RAM
    * 128GB disk
    * NAT network
    * USB 3.1
    * Disable 3D graphics acceleration
    * TPM
    * Attach 3 optical drives:
      * Windows 11 ISO
      * unattend.iso
        * unattend.iso is generated with [Christoph Schneegans's autounattend.xml generator](https://schneegans.de/windows/unattend-generator/?LanguageMode=Unattended&UILanguage=en-US&Locale=ja-JP&Keyboard=0411%3A%7B03b5835f-f03c-411b-9ce2-aa23e1171e36%7D%7Ba76c93d9-5523-4e90-aafa-4db112f9ac76%7D&GeoLocation=122&ProcessorArchitecture=amd64&ComputerNameMode=Custom&ComputerName=REFLA&CompactOsMode=Default&TimeZoneMode=Explicit&TimeZone=Tokyo+Standard+Time&PartitionMode=Unattended&PartitionLayout=GPT&EspSize=300&RecoveryMode=None&DiskAssertionMode=Skip&WindowsEditionMode=Generic&WindowsEdition=enterprise&UserAccountMode=Unattended&AccountName0=User&AccountDisplayName0=&AccountPassword0=&AccountGroup0=Administrators&AccountName1=&AccountName2=&AccountName3=&AutoLogonMode=Own&PasswordExpirationMode=Unlimited&LockoutMode=Disabled&HideFiles=None&ShowFileExtensions=true&ClassicContextMenu=true&ShowEndTask=true&TaskbarSearch=Hide&TaskbarIconsMode=Default&DisableWidgets=true&DisableBingResults=true&StartTilesMode=Default&StartPinsMode=Empty&DisableDefender=true&DisableWindowsUpdate=true&DisableSmartScreen=true&DisableFastStartup=true&DisableSystemRestore=true&PreventDeviceEncryption=true&HideEdgeFre=true&EffectsMode=Performance&DesktopIconsMode=Default&VMwareTools=true&WifiMode=Skip&ExpressSettings=DisableAll&KeysMode=Skip&ColorMode=Default&WallpaperMode=Default&Remove3DViewer=true&RemoveBingSearch=true&RemoveCalculator=true&RemoveCamera=true&RemoveClipchamp=true&RemoveClock=true&RemoveCopilot=true&RemoveCortana=true&RemoveDevHome=true&RemoveFamily=true&RemoveFeedbackHub=true&RemoveGetHelp=true&RemoveHandwriting=true&RemoveMailCalendar=true&RemoveMaps=true&RemoveMathInputPanel=true&RemoveMediaFeatures=true&RemoveMixedReality=true&RemoveZuneVideo=true&RemoveNews=true&RemoveNotepad=true&RemoveOffice365=true&RemoveOneDrive=true&RemoveOneNote=true&RemoveOneSync=true&RemoveOutlook=true&RemovePaint3D=true&RemovePeople=true&RemovePhotos=true&RemovePowerAutomate=true&RemoveQuickAssist=true&RemoveRecall=true&RemoveSkype=true&RemoveSnippingTool=true&RemoveSolitaire=true&RemoveSpeech=true&RemoveStepsRecorder=true&RemoveStickyNotes=true&RemoveTeams=true&RemoveGetStarted=true&RemoveToDo=true&RemoveVoiceRecorder=true&RemoveWallet=true&RemoveWeather=true&RemoveFaxAndScan=true&RemoveWindowsHello=true&RemoveWindowsMediaPlayer=true&RemoveZuneMusic=true&RemoveWordPad=true&RemoveXboxApps=true&RemoveYourPhone=true&FirstLogonScript0=%23+Japanese+language+pack%0D%0AInstall-Language+ja-JP+-CopyToSettings%0D%0ASet-SystemPreferredUILanguage+ja-JP%0D%0ASet-WinUILanguageOverride+-Language+ja-JP%0D%0ASet-WinCultureFromLanguageListOptOut+-OptOut+%24False%0D%0ASet-WinHomeLocation+-GeoId+0x7A%0D%0ASet-WinSystemLocale+-SystemLocale+ja-JP%0D%0ASet-WinUserLanguageList+-LanguageList+ja-JP+-Force%0D%0ASet-WinDefaultInputMethodOverride+-InputTip+%220411%3A00000411%22%0D%0ACopy-UserInternationalSettingsToSystem+-welcomescreen+%24true+-newuser+%24true%0D%0A%0D%0A%23+JIS+keyboard%0D%0ASet-ItemProperty+HKLM%3A%5C%5CSystem%5C%5CCurrentControlSet%5C%5CServices%5C%5Ci8042prt%5C%5CParameters+-name+%22LayerDriver+JPN%22+-value+%22kbd106.dll%22%0D%0ASet-ItemProperty+HKLM%3A%5C%5CSystem%5C%5CCurrentControlSet%5C%5CServices%5C%5Ci8042prt%5C%5CParameters+-name+%22OverrideKeyboardIdentifier%22+-value+%22PCAT_106KEY%22%0D%0ASet-ItemProperty+HKLM%3A%5C%5CSystem%5C%5CCurrentControlSet%5C%5CServices%5C%5Ci8042prt%5C%5CParameters+-name+%22OverridekeyboardSubtype%22+-value+%222%22%0D%0ASet-ItemProperty+HKLM%3A%5C%5CSystem%5C%5CCurrentControlSet%5C%5CServices%5C%5Ci8042prt%5C%5CParameters+-name+%22OverridekeyboardType%22+-value+%227%22%0D%0A%0D%0A%23+Remap+caps+lock+to+control%0D%0A%24hexified+%3D+%2200%2C00%2C00%2C00%2C00%2C00%2C00%2C00%2C02%2C00%2C00%2C00%2C1d%2C00%2C3a%2C00%2C00%2C00%2C00%2C00%22.Split%28%27%2C%27%29+%7C+%25+%7B+%220x%24_%22%7D%0D%0A%24RegistryPath+%3D+%27HKLM%3A%5C%5CSystem%5C%5CCurrentControlSet%5C%5CControl%5C%5CKeyboard+Layout%27%0D%0Aif+%28-NOT+%28Test-Path+%24RegistryPath%29%29+%7B%0D%0A++New-ItemProperty+-Path+%24RegistryPath+-Name+%22Scancode+Map%22+-PropertyType+Binary+-Value+%28%5Bbyte%5B%5D%5D%24hexified%29%0D%0A%7D+else+%7B%0D%0A++Set-ItemProperty+-Path+%24RegistryPath+-Name+%22Scancode+Map%22+-Value+%28%5Bbyte%5B%5D%5D%24hexified%29%0D%0A%7D%0D%0A%0D%0A%23+FLARE+VM%0D%0Acd+%24env%3ATEMP%0D%0AInvoke-WebRequest+-Uri+%22https%3A%2F%2Fraw.githubusercontent.com%2Ffireeye%2Fflare-vm%2Fmaster%2Finstall.ps1%22+-OutFile+install.ps1%0D%0AUnblock-File+.%5C%5Cinstall.ps1%0D%0ASet-ExecutionPolicy+Unrestricted+-Force%0D%0A.%5C%5Cinstall.ps1+-noPassword+-noWait+-noGui+-noChecks&FirstLogonScriptType0=Ps1&WdacMode=Skip)
      * VMWare Tools ISO

 3. Power on to the firmware and boot from Windows 11 ISO
 4. Remove unattend.iso and VMWare Tools optical drives
 5. Eject installer disc
 6. Disconnect the VM from network and take a snapshot
