# thinkmac-t470

_**Tested on:** macOS Mojave 10.14.x, macOS Catalina 10.15.x_

_**Apple Services:** iCloud, iMessage, FaceTime, etc. tested and working!_

![macOS Catalina on the ThinkPad T470](/macos-t470.png)

## Introduction
This project is designed to help other T470 owners get a fully working macOS installation on their Thinkpads. Maybe you don't have a T470 but have run into a problem with a specific hardware device that is shared between this system and yours. Either way, Welcome! If you run into an issue with this guide or have a suggestion, feel free to submit an issue. I will maintain this as best I can with more updates coming soon to this guide.

## Disclaimer & Notes
- ___*Always*_ keep a copy of your disassembled DSDT file and back it up as you apply patches.__
  - On top of this, I also keep each patch in a separate txt file in case I need to rebuild my DSDT
- To keep power management and battery life under control, I have disabled always-on USB and wake from thunderbolt
- Battery life is currently on par with what I was getting under Windows
- I haven't experienced a single kernel panic or other crash on Mojave or Catalina
- Your results may vary, submit an issue if you need help and I'll do my best to help you
 
## Hardware
#### Thinkpad T470 (2019)
- Part Number: 20JMS0Q400
- BIOS 1.61 (N1QUJ27W)
  - Set default config
  - Config > USB > Always on USB: Disabled
  - Config > Thunderbolt 3 > All options: Disabled (No Security)
  - Security > Security Chip: Disabled (TPM2.0)
  - Security > I/O Port Access: WWAN, Fingerprint, TB3, WiGig: Disabled
  - Security > Secure Boot > Secure Boot: disabled
  - Startup > Boot Mode: UEFI Only
  - Startup > CSM Support: Disabled
  
#### Tested and working
- Intel Core i7-7300U @ 2.6GHz
- Intel HD Graphics 620                             
- 1920x1080 IPS Panel (Matte)
- 8GB DDR4 2133Mhz                      
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
- Intel Dual-Band Wireless AC 8260 (vPro) (buggy but works)


#### Untested
  - Realtek USB Card Reader (0BDA:0316)
  - _WWAN (M.2 2242 "B") - Empty Slot_
  - Function/Media Keys (aside from Vol/Bright)
  - Headphone jack
  - Thunderbolt 3
  
#### Unsupported
- Fingerprint reader (Validity Sensors - 138a:0097)
- Touchscreen (Raydium Touch Systems)

## Tools

- USB flash drive with macOS Installer & CLOVER
  - Windows - [gibMacOS](https://github.com/corpnewt/gibMacOS)
  - macOS & Linux - [macos_usb](https://github.com/notthebee/macos_usb)
- Clover Configurator
- iasl (needed to disassemble ACPI files)
- MaciASL (needed to patch and assemble ACPI files)
- IORegistryExplorer (good for troubleshooting and needed to create custom SSDT for USBInjectAll)

## Getting Started

Everything described below is already contained in the EFI folder, though some kexts may not be the latest version available by the time you read this. Since not all models of the ThinkPad T470 are completely the same, I'm including the methods I used to get the individual devices working which can be cherrypicked to finalize your setup.

### Minimum required to boot installer

If you're just getting started and you've got yourself a bootable USB installer with CLOVER loaded on it, go ahead and install these kexts to `/EFI/CLOVER/kexts/Other` and place the config.plist under `/EFI/CLOVER`. I found these necessary to get the installer running and macOS installed. Most things such as battery status, brightness control, audio, etc. will not work but that's expected.

- [config.plist for HD 620](https://github.com/RehabMan/OS-X-Clover-Laptop-Config/blob/master/config_HD615_620_630_640_650.plist)
- [Lilu](https://github.com/acidanthera/Lilu)
- [WhateverGreen](https://github.com/acidanthera/WhateverGreen)
- VirtualSMC
  - SMCBatteryManager
  - SMCLightSensor
  - SMCProcessor
  - SMCSuperIO
- VoodooPS2Controller (RehabMan's version)
- IntelMausiEthernet
- USBInjectAll

## Battery

Since the ThinkPad T470 has two batteries (internal & removable), we need to use a patch that will present both batteries as one to the system. From this repo, grab `SSDT-BATC-T470.aml` and place it under `/EFI/CLOVER/ACPI/patched`. You will also need to apply a DSDT patch located at `Extras/DSDT Patch/Battery Indicator` via MaciASL.

Now in order to get the battery status indicator working, we need to apply a DSDT hotpatch via Clover Configurator. Open the config.plist from your EFI partition in Clover Configurator and select ACPI from the sidebar. Under DSDT\Patches we'll add these four `change Notify` lines:

![battery-notify](/Extras/battery-notify.png)

## Audio
In order to get the ALC298 chipset working, we'll need to make use of [AppleALC.kext](https://github.com/acidanthera/AppleALC) (which requires [Lilu.kext](https://github.com/acidanthera/Lilu)). Download the latest versions and place them under `/EFI/CLOVER/kexts/Other`.

Now that we have the plugin, we need to tell Clover how to use it. Open your config.plist in Clover Configurator and use one of the two methods below:

1. **Add property under Devices\Properties:**

  ![img_applealc_config](/Extras/applealc-config.png)

2. **Add boot argument under Boot\Arguments:** `alcid=47`

> _**Tip:** Try running `lspci | grep audio` or `aplay -l` from a Linux live USB to find which codec your system has (e.g. ALC298)._


## Ethernet

Getting the onboard network adapter working only requires placing [IntelMausiEthernet](https://github.com/RehabMan/OS-X-Intel-Network) under `/EFI/CLOVER/kexts/Other`.
    
> _**Warning:** For some reason, I couldn't get this to work with the installer so I used a USB to Ethernet adapter. Once macOS was installed I was able to use the onboard network adapter._


## Backlight

The backlight works but we need to be able to control its brightness. Place the `SSDT-PNLF.aml` from my EFI folder inside of the `/EFI/CLOVER/ACPI/patched` directory and put [AppleBacklightFixup.kext](https://github.com/RehabMan/AppleBacklightFixup) under `/EFI/CLOVER/kexts/Other`. These alone should give you control of the backlight under System Preferences.

In order to control the backlight using the brightness keys involves patching the DSDT.

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
            
## Function and Media Keys
> Coming soon

## SD Card Reader
> Coming soon

## Touchpad

> _**Info:** For my Synaptics touchpad, I was able to get it working using RehabMan's VoodooPS2Controller.kext but tluck's SSDT-Thinkpad_Clickpad patch was required to enable the PrefPane. Multi-touch gestures are fairly limited. You can utilize two finger scrolling but swiping to go back a page in Safari, pinch-to-zoom and rotate don't work. I would also recommend disabling tap-to-click as this caused the cursor to intermittently jump to a second position on the screen if you touched the touchpad simultaneoulsy with a second finger._

> _**Note:** To enable three finger gesture for Exposé you must define the gesture as a keyboard shortcut under SysPrefs > Keyboard > Shortcuts. Under Mission Control, select Application Windows and make the gesture on the touchpad to set it._

- [VoodooPS2Controller.kext](https://github.com/RehabMan/OS-X-Voodoo-PS2-Controller)
  - **Location:** /EFI/CLOVER/kexts/Other
- SSDT-Thinkpad_Clickpad.aml
  - **Location:** /EFI/CLOVER/ACPI/patched

## USB (Camera, USB ports, etc.)
It is easiest to just use RehabMan's guide [here](https://www.tonymacx86.com/threads/guide-creating-a-custom-ssdt-for-usbinjectall-kext.211311/) to create a custom SSDT. It seems difficult at first but it's really quite easy. You can also take a look at my SSDT-UIAC-T470.dsl to get an idea of how it should look. I've left comments pertaining to which logical device belongs to which physical device. I would also recommend disabling (which is done by commenting out `//` those lines) things that aren't supported like the touchscreen, fingerprint reader, etc.

## Power Management (Sleep, wake, battery life, etc.)
> Coming soon

## Post-installation work (Serial, UUID)
Make sure you generate a new serial number and UUID in Clover Configurator to avoid any conflicts with iCloud, iMessage, etc. I've removed some of my unique identifiers so they

## Special Thanks
- [digitalec](https://github.com/digitalec/thinkmac-t470) - Starter repo, modified to work for 7th gen
- [okay](https://github.com/okay/t470) - some good info here which kickstarted my efforts
- [RehabMan](https://github.com/RehabMan) - base config.plist for Intel 520, various kexts, DSDT patches and SSDTs
- [tluck](https://github.com/tluck/Lenovo-T460-Clover/tree/master/DSDT.T470) - modified version of RehabMan's SSDT-BATC; SSDT-Thinkpad_Clickpad
- [ImmersiveX](https://github.com/ImmersiveX/clover-theme-minimal-dark) - dark theme for Clover
