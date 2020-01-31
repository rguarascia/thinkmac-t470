# thinkmac-t470

_**Supports:** macOS Catalina 10.15.x including iCloud, iMessage, FaceTime, etc._

![macOS Catalina on the ThinkPad T470](/macos-t470.png)

## I. Introduction

## II. Hardware
### Thinkpad T470 (2019)
- Part Number: 20JMS0Q400
- BIOS 1.60 (N1QET85W)
  - Set default config
  - Secure Boot: disabled
  - Boot Mode: UEFI Only
  - CSM Support: enabled
  
### Tested and working
- Intel Core i7-6600U @ 2.6GHz / 3.4Ghz Turbo       
- Intel HD Graphics 520                             
- 16GB DDR4 2666Mhz (SK Hynix)                      
- Intel SSD Pro 7600P 512GB NVME                    
- Dual 3-cell batteries                             
- USB - XHC 100-series chipset (8086:9d2f)          
- Realtek ALC298                                    
- Integrated Camera (IMC Networks)                  
- Intel I219-LM Network Adapter                     
- Touchpad (Synaptics UltraNav)                     
- Trackpoint                                        
- Keyboard backlight                                
- LCD backlight                                     
- Sleep/wake                                        
- Power button                                      
- Power management                                  
- Thinkpad/Power button LED (sleep mode)            

### Untested
  - Realtek USB Card Reader (0BDA:0316)
  - _WWAN (M.2 2242 "B") - Empty Slot_
  - Function/Media Keys (aside from Vol/Bright)
  - Headphone jack
  - Thunderbolt 3
  
### Unsupported
- Intel Dual-Band Wireless AC 8260 (vPro)
- Fingerprint reader (Validity Sensors - 138a:0097)
- Touchscreen (Raydium Touch Systems)
 
## III. Hardware Setup and Configuration

> _**Info:** Everything you see below is already contained in the EFI folder. Since not all models of the ThinkPad T470 are completely the same, I'm including the methods I used to get the individual modules working which can be cherrypicked to finalize your setup._

> _**Usage:** For usage information or support on a specific kext, follow the associated link to its repository page._

### Prerequisites

> _**Info:** These are needed to get this off the ground. Place the kexts on your EFI partition under **/CLOVER/kexts/Other** and config.plist under **/CLOVER**_
   
- [Lilu.kext](https://github.com/acidanthera/Lilu)
- [WhateverGreen.kext](https://github.com/acidanthera/WhateverGreen)
- VirtualSMC.kext
  - SMCBatteryManager.kext
  - SMCLightSensor.kext
  - SMCProcessor.kext
  - SMCSuperIO.kext
- [config.plist for HD 520](https://github.com/RehabMan/OS-X-Clover-Laptop-Config/blob/master/config_HD515_520_530_540.plist)
  

### Battery

> _**Info:** The ThinkPad T470 has two batteries, an internal and external (a.k.a removable). This uses an SSDT patch to make macOS see the two batteries as one large battery._

- SSDT-BATC-T470.aml
  - **Location:** /EFI/CLOVER/ACPI/patched 
- config.plist (DSDT Patches)
  - **Add via Clover Configurator:** ACPI > DSDT > Patches
     
       | comment                                    | find | replace |
       |--------------------------------------------|------|---------|
       | change Notify(\_SB.BAT0 to Notify(_SB.BATC | _SB.BAT0 | _SB.BATC |
       | change Notify(\_SB.BAT1 to Notify(_SB.BATC | _SB.BAT1 | _SB.BATC |
       | change Notify(BAT0 to Notify(BATC          | BAT0     | BATC     |
       | change Notify(BAT0 to Notify(BATC          | BAT1     | BATC     |

### Audio
- In order to get the ALC298 chipset working, we'll need to make use of [AppleALC.kext](https://github.com/acidanthera/AppleALC) (which requires [Lilu.kext](https://github.com/acidanthera/Lilu)). Download the latest version and place them in the `kexts\Other` directory on your EFI partition.
- Now that we have the kexts, we need to tell Clover how to use them. Open your config.plist in Clover Configurator and use one of the two methods below:
  1. Add property under Devices\Properties:
  ![img_applealc_config](/Extras/applealc-config.png)

> _**Tip:** Try running `lspci | grep audio` or `aplay -l` from a Linux live USB to find which codec your system has (e.g. ALC298)._

- config.plist 
  - **Option 1** - Set Device Property (via Clover Configurator under Devices\Properties)
    
    | Properties Key | Properties Value | Value Type |
    |----------------|------------------|:----------:|
     | layout-id      | 3                | DATA       |
    
      > _**Note:** You'll need to know the PCI location. I only had two entries appear: one for the iGPU (should have key named "ig-platform-id") and another for onboard audio (PciRoot(0)/Pci(0x1f,3)._
        
  - **Option 2** - Use Boot Argument
    - **Add via Clover Configurator:** Boot > Arguments
        `alcid=47`

### Ethernet
  - [IntelMausiEthernet.kext](https://github.com/RehabMan/OS-X-Intel-Network)
    - **Location:** /EFI/CLOVER/kexts/Other
    
  > _**Note:** For some reason, I couldn't get this to work with the installer so I used a USB to Ethernet adapter. It does work after booting the first time.


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

> _**Note:** This section is still a work in progress. I haven't had time to play around with the remaining "special keys" such as Settings (F9), Bluetooth (F10), On-screen Keyboard (F11) and Favorites (F12). I imagine these will require a similar DSDT patch as the brightness keys by determining the keys ID via ACPIDebug.kext._
- Working:
  - Mute, VolUp, VolDown, BrightDown, BrightUp
- Not Working (yet):
  - F1-F12, Mic, Display, Airplane, Settings, Bluetooth, OSK, Favorites

### SD Card Reader

> _**Coming soon:** This section is still a work in progress. I don't have a regular need for this so it's definitley the last thing on my list, however I did stumble across a kext patch that may work. I'll test this out and update._

### Touchpad

> _**Info:** For my Synaptics touchpad, I was able to get it working using RehabMan's VoodooPS2Controller.kext but tluck's SSDT-Thinkpad_Clickpad patch was required to enable the PrefPane. Multi-touch gestures are fairly limited. You can utilize two finger scrolling but swiping to go back a page in Safari, pinch-to-zoom and rotate don't work. I would also recommend disabling tap-to-click as this caused the cursor to intermittently jump to a second position on the screen if you touched the touchpad simultaneoulsy with a second finger._

> _**Note:** To enable three finger gesture for Exposé you must define the gesture as a keyboard shortcut under SysPrefs > Keyboard > Shortcuts. Under Mission Control, select Application Windows and make the gesture on the touchpad to set it._

- [VoodooPS2Controller.kext](https://github.com/RehabMan/OS-X-Voodoo-PS2-Controller)
  - **Location:** /EFI/CLOVER/kexts/Other
- SSDT-Thinkpad_Clickpad.aml
  - **Location:** /EFI/CLOVER/ACPI/patched

### USB (Camera, USB ports, etc.)
Using USBInjectAll, I was able to build a custom SSDT (SSDT-UIAC) to only enable the ports that are physically present. I disabled the internal USB port designated for biometrics since it doesn't work anyway.

### Power Management (Sleep, wake, battery life, etc.)
CPUFriend (KEXT) + CPUFriendFriend (SSDT patch) has allowed me to run the system down to 800Mhz and has prevented the CPU fan from running as often. Temps however around 45-50C when idle which is a little higher than I like but it doesn't seem to hurt anything.

***

### Post-installation work (Serial, UUID)
Make sure you generate a new serial number and UUID in Clover Configurator to avoid any conflicts with iCloud, iMessage, etc. I've removed some of my unique identifiers so they

### Special Thanks
- [okay](https://github.com/okay/t470) - some good info here which kickstarted my efforts
- [RehabMan](https://github.com/RehabMan) - base config.plist for Intel 520, various kexts, DSDT patches and SSDTs
- [tluck](https://github.com/tluck/Lenovo-T460-Clover/tree/master/DSDT.T470) - modified version of RehabMan's SSDT-BATC; SSDT-Thinkpad_Clickpad
- [ImmersiveX](https://github.com/ImmersiveX/clover-theme-minimal-dark) - dark theme for Clover
