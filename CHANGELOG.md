### Changelog
## 13 Nov 2019
  - Initial release based on 10.15.1

## 25 Jan 2020
  - Supports Catalina 10.15.2
  - Updated KEXTs:
    - Lilu, WhateverGreen and AppleALC to latest
  - Removed several unused KEXTs
  - Reverted back to FakeSMC due to issues with VirtualSMC
    - Fixes: Boot time reduced by 30s+
    - Fixes: Several minute delay after boot before airportd would start resulting in no WiFi initially
