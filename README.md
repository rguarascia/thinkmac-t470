# Lenovo ThinkPad T470 (Type 20JM) Hackintosh

_**Supports:** macOS Catalina 10.15.1 including iCloud, iMessage, FaceTime, etc._

![macOS Catalina on the ThinkPad T470](/macos-t470.png)

### Introduction
This is my attempt at outlining the necessary configuration and dependencies to get macOS running on a ThinkPad T470. There's quite a lot of useful Reddit & forum posts, guides and other repositories here on GitHub that I was able to pull small bits of information from in order to make this guide. One problem that I discovered is that the T470 has shipped with many different hardware configurations making a one-size-fits-all approach impossible. Another other problem I found is that many of the sources I used didn't provide enough detail making the learning curve a little more challenging. In turn, I decided to create this for anyone else who may have recently purchased one of these T470 models (specifically, Type 20JM) that Lenovo has had on sale recently.

### Disclaimer
**Be careful!** Be sure to make backups as you modify your EFI partition in case you break something. In the information below, you'll see that I store all my kexts on the EFI partition. I don't know if there is any benefit to copying these files to either /S/L/E or /L/E but I haven't seen the need to. One advantage to this method is that despite system updates, the kext files are safe on the EFI partition from being deleted or modified.

***

### ThinkPad T470 (Type 20JM) Specs
* **Part Number:** 20JMS0Q400
* **BIOS:** 1.60 (N1QET85W)
    * **Set default config**
    * **Secure Boot:** disabled
    * **Boot Mode:** UEFI Only
    * **CSM Support:** enabled

|                      | Hardware                                      | Working | Supported in            |
| -------------------- | --------------------------------------------- |:-------:|:-----------------------:|
| **CPU**              | Intel Core i7-6600U @ 2.6GHz (3.4GHz Turbo)   | Yes     | config.plist            |
| **Graphics**         | Intel HD Graphics 520                         | Yes     | config.plist            |
| **Memory**           | 16GB DDR4 2666Mhz (SK Hynix)                  | Yes     | - |
| **Storage**          | Intel SSD Pro 7600P 512GB NVMe                | Yes     | - |
| **Battery**          | 3 + 3-cell (Internal + Removable)             | Yes     | ACPIBatteryManager.kext |
| **USB**              | XHC 100-series chipset (8086:9d2f)            | Yes     | USBInjectAll.kext |
| **Card Reader (SD)** | Realtek USB 3.0 Card Reader (0BDA:0316)       | WIP | - |
| **Audio**            | Realtek ALC298                                | Yes     | AppleALC.kext, layout-id 3 |
| **Camera**           | IMC Networks Integrated Camera                | Yes     | USBInjectAll.kext |
| **Ethernet**         | Intel I219-LM                                 | Yes     | IntelMausiEthernet.kext |
| **WiFi/Bluetooth**   | Intel Dual-Band Wireless-AC 8260 (vPro)       | No¹     | - |
| **Function/Media keys** |                                            | Yes     | - |
| **Fingerprint Reader**| Validity Sensors (138a:0097)                 | No      | - |
| **Touchpad**         | Synaptics UltraNav                            | Yes     | VoodooPS2Controller.kext, SSDT |
| **Trackpoint**       |                                               | Yes²     | VoodooPS2Controller.kext |
| **Backlight**        |                                               | Yes     | AppleBacklightFixup.kext, SSDT |
| **Touchscreen**      | AU Optronics Touchscreen                      | No      | - |
| **Sleep/Wake**       |                                               | WIP     | - |
| **Power Button**     |                                               | Yes     | - |
| **Power Management** |                                               | WIP     | ACPIPowerManagement.kext |
| **Headphone Jack**   |                                               | -       | - |
| **Thunderbolt**      |                                               | -       | - |
| **Other**            | ThinkPad Ultra Dock (90w)                     | Yes³    | - |

¹Bluetooth appears to be detected and allows you to scan but never detects devices.

²Trackpoint isn't smooth and jumps around a lot; I haven't looked into this so there could be improvement.

³Only have tested USB3, ethernet and charging; video output untested.

## TODO

- Create custom SSDT injector for XHC 100-series chipset (8086:9d2f)

## Known Issues

- Power Management still needs to be looked into

  - Sleep appears to work but battery drain is horrendous while sleeping (100% to 0% in < 8h)

  - Battery life overall is pretty terrible (only getting ~1.5h on a full charge)
  
- I found a patch to enable the SD card reader but haven't had a chance to implement it yet
  

## Hardware Setup and Configuration

> _**Info:** Everything you see below is already contained in the EFI folder. Since not all models of the ThinkPad T470 are completely the same, I'm including the methods I used to get the individual modules working which can be cherrypicked to finalize your setup._

> _**Usage:** For usage information or support on a specific kext, follow the associated link to its repository page._

### Prerequisites

   > _**Info:** These are needed to get this off the ground. Place the kexts under **/EFI/CLOVER/kexts/Other** and config.plist under **/EFI/CLOVER**_
  
  - [Lilu.kext](https://github.com/acidanthera/Lilu)
  - [WhateverGreen.kext](https://github.com/acidanthera/WhateverGreen)
  - [FakeSMC.kext](https://github.com/RehabMan/OS-X-FakeSMC-kozlek)
  - [config.plist for HD 520](https://github.com/RehabMan/OS-X-Clover-Laptop-Config/blob/master/config_HD515_520_530_540.plist)
  

### Battery

> _**Info:** The ThinkPad T470 has two batteries, an internal and external (a.k.a removable). This uses an SSDT patch to make macOS see the two batteries as one large battery._

  - SSDT-BATC-T470.aml
  
    - **Location:** /EFI/CLOVER/ACPI/patched
    
  - [ACPIBatteryManager.kext](https://github.com/RehabMan/OS-X-ACPI-Battery-Driver)
  
    - **Location:** /EFI/CLOVER/kexts/Other
    
  - config.plist (DSDT Patches)
  
    - **Add via Clover Configurator:** ACPI > DSDT > Patches
     
       | comment                                    | find | replace |
       |--------------------------------------------|------|---------|
       | change Notify(\_SB.BAT0 to Notify(_SB.BATC | _SB.BAT0 | _SB.BATC |
       | change Notify(\_SB.BAT1 to Notify(_SB.BATC | _SB.BAT1 | _SB.BATC |
       | change Notify(BAT0 to Notify(BATC          | BAT0     | BATC     |
       | change Notify(BAT0 to Notify(BATC          | BAT1     | BATC     |

### Audio

> _**Info:** This was fairly straightforward. You'll need to know which codec your system has which you can find by booting from a Linux live USB. Try running `lspci | grep audio` or `aplay -l`. My ALC298 works with a layout-id of 3._

  - [AppleALC.kext](https://github.com/acidanthera/AppleALC)
  
  - [Lilu.kext](https://github.com/acidanthera/Lilu)

    - **Both kexts located at:** /EFI/CLOVER/kexts/Other
    
  - config.plist
  
     - **Option 1** - Set Device Property
  
       - **Add via Clover Configurator:** Devices > Properties
    
           | Properties Key | Properties Value | Value Type |
           |----------------|------------------|:----------:|
           | layout-id      | 3                | DATA       |
    
         > _**Note:** You'll need to know the PCI location. I only had two entries appear: one for the iGPU (should have key named "ig-platform-id") and another for onboard audio (PciRoot(0)/Pci(0x1f,3)._
        
    - **Option 2** - Use Boot Argument
  
      - **Add via Clover Configurator:** Boot > Arguments
      
        `alcid=3`

### Ethernet

  - [IntelMausiEthernet.kext](https://github.com/RehabMan/OS-X-Intel-Network)
  
    - **Location:** /EFI/CLOVER/kexts/Other


### Backlight

  - SSDT-PNLF.aml
  
    - **Location:** /EFI/CLOVER/ACPI/patched
    
  - [AppleBacklightFixup.kext](https://github.com/RehabMan/AppleBacklightFixup)
  
    - **Location:** /EFI/CLOVER/kexts/Other
    
  -  Brightness Controls
  
     > _**Note:** My model's brightness keys (Fn+F5 & Fn+F6) uses ACPI not PS2. To determine the key name (\_Q14, \_Q15 below) please see RehabMan's [ACPIDebug.kext](https://github.com/RehabMan/OS-X-ACPI-Debug)._
     
     > _**Compatibility Note:** If using ACPIDebug.kext to determine keys, syslog/Console.app will not show these anymore. From Terminal run `log show --last 5 | grep ACPIDebug` instead._

     - *Requires DSDT patch; my model uses LPC**B**.KBD **not** LPC.PS2M or LPC.PS2K*

            Method (_Q14, 0, NotSerialized)  // _Qxx: EC Query
            {

                // Brightness Up
                Notify(\_SB.PCI0.LPCB.KBD, 0x0206)
                Notify(\_SB.PCI0.LPCB.KBD, 0x0286)

            }

            Method (_Q15, 0, NotSerialized)  // _Qxx: EC Query
            {

                // Brightness Down
                Notify(\_SB.PCI0.LPCB.KBD, 0x0205)
                Notify(\_SB.PCI0.LPCB.KBD, 0x0285)

            }
            
### Function and Media Keys

> _**Note:** This section is still a work in progress. I haven't had time to play around with the remaining "special keys" such as Settings (F9), Bluetooth (F10), On-screen Keyboard (F11) and Favorites (F12). I imagine these will require a similar DSDT patch as the brightness keys by determining the keys ID via ACPIDebug.kext.

### SD Card Reader

> _**Note:** This section is still a work in progress. I don't have a regular need for this so it's definitley the last thing on my list, however I did stumble across a kext patch that may work. I'll test this out and update.

### Touchpad

> _**Info:** For my Synaptics touchpad, I was able to get it working using RehabMan's VoodooPS2Controller.kext but tluck's SSDT-Thinkpad_Clickpad patch was required to enable the PrefPane. Multi-touch gestures are fairly limited. You can utilize two finger scrolling but swiping to go back a page in Safari, pinch-to-zoom and rotate don't work. I would also recommend disabling tap-to-click as this caused the cursor to jump to a second position on the screen if you touched the touchpad simultaneoulsy with a second finger._

> _**Note:** To enable three finger gesture for Exposé you must define the gesture as a keyboard shortcut under SysPrefs > Keyboard > Shortcuts. Under Mission Control, select Application Windows and make the gesture on the touchpad to set it._

- [VoodooPS2Controller.kext](https://github.com/RehabMan/OS-X-Voodoo-PS2-Controller)

  - **Location:** /EFI/CLOVER/kexts/Other

- SSDT-Thinkpad_Clickpad.aml

  - **Location:** /EFI/CLOVER/ACPI/patched

***

### Post-installation work (Serial, UUID)
Make sure you generate a new serial number and UUID in Clover Configurator to avoid any conflicts with iCloud, iMessage, etc.

### Special Thanks
- [okay](https://github.com/okay/t470) - some good info here which kickstarted my efforts
- [RehabMan](https://github.com/RehabMan) - base config.plist for Intel 520, various kexts, DSDT patches and SSDTs
- [tluck](https://github.com/tluck/Lenovo-T460-Clover/tree/master/DSDT.T470) - modified version of RehabMan's SSDT-BATC; SSDT-Thinkpad_Clickpad
- [ImmersiveX](https://github.com/ImmersiveX/clover-theme-minimal-dark) - dark theme for Clover
