## Changelog

#### v2.4 _(February 3, 2020)_
  - Tested on macOS Mojave 10.14.6
  - Fixed: Audio device no longer disappears with new power management using CPUFriend/CPUFriendFriend
  - Fixed: Cleaned up and renamed SSDTs as appropriate
  - Fixed: LED no longer is stuck after sleep. This was due to an incorrect USB _PRW patch being applied.
  - Improvement: Modified several BIOS options to help reduce battery consumption (see README)
  - Improvement: Built new DSDT with new BIOS changes
  - Added: FileVault2 tested and fully works on Mojave and Catalina
  - Added: DSDT-stockbios-nosecureboot.dsl for default BIOS settings is included under ACPI/patched-dsl

#### v2.3 _(January 29, 2020)_
  - Fixed: Battery drain over 6hr period sleeping was just under 2% (approx. 350hrs/14.5 days on full charge) thanks to Instant Wake fix by RehabMan
    - Side affect: "Breathing" LED is stuck after wake even with patch applied under NVSS
  - Rebuilt custom USB SSDT with touchscreen and biometrics disabled
  - Fixed "restart on shutdown" bug by applying DSDT patch
  - Added "Extras" directory which includes individual DSDT patches
  - Moved \*.DSL files to their own directory
  - Cleaned up unused/leftover files
  
#### v2.2.1 _(January 26, 2020)_
  - Disabled HDAS to HDEF DSDT patch per AppleALC instruction
  - Switched back (again) to VirtualSMC after identifying ACPIBatteryManager as conflicting with SMCBatteryManager
  
#### v2.2 _(January 25, 2020)_
  - Supports Catalina 10.15.2
  - Updated KEXTs:
    - Lilu, WhateverGreen and AppleALC to latest
  - Removed several unused KEXTs
  - Reverted back to FakeSMC due to issues with VirtualSMC
    - Fixes: Boot time reduced by 30s+
    - Fixes: Several minute delay after boot before airportd would start resulting in no WiFi initially
  - Updated config.plist:
    - DefaultVolume set to LastBootedVolume
  - AppleALC: changed layout-id from '3' to '47' to see if this fixes disappearing audio device on wake
  
  #### v1.0 _(November 13, 2019)_
  - Initial release based on 10.15.1
