## Changelog
#### v1.0 (13 Nov 2019)
  - Initial release based on 10.15.1

#### v2.2 (25 Jan 2020)
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

#### v2.3 (26 Jan 2020)
  - Disabled HDAS to HDEF DSDT patch per AppleALC instruction



## Known Issues
  - Audio device still disappearing after sleep but not everytime now
  - HEVC videos do not play even though HEVC is supported (per VideoProc)
