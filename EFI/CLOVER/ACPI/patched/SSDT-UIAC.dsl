// Automatic injection of XHC properties

DefinitionBlock ("", "SSDT", 2, "HACK", "UIAC", 0)
{
    Device(UIAC)
    {
        Name(_HID, "UIA00000")
        Name(RMCF, Package()
        {
            "8086_9d2f", Package()
            {
                "port-count", Buffer() { 26, 0, 0, 0 },
                "ports", Package()
                {
                    "HS01", Package()   // USB2_3 Left rear & dock connector
                    {
                        "UsbConnector", 3,
                        "port", Buffer() { 1, 0, 0, 0 },
                    },
                    "HS02", Package()   // USB2_3 Right rear (below Enter key)
                    {
                        "UsbConnector", 3,
                        "port", Buffer() { 2, 0, 0, 0 },
                    },
                    "HS04", Package()   // USB2_3 Right front (below biometrics)
                    {
                        "UsbConnector", 3,
                        "port", Buffer() { 4, 0, 0, 0 },
                    },
                    "HS07", Package()   // USB2 Bluetooth (internal)
                    {
                        "UsbConnector", 255,
                        "port", Buffer() { 7, 0, 0, 0 },
                    },
                    "HS08", Package()   // USB2 Camera (internal)
                    {
                        "UsbConnector", 255,
                        "port", Buffer() { 8, 0, 0, 0 },
                    },
                    "HS10", Package()   // Touchscreen
                    {
                        "UsbConnector", 255,
                        "port", Buffer() { 10, 0, 0, 0 },
                    },
                    "SS01", Package()    // USB2_3 Left rear & dock connector
                    {
                        "UsbConnector", 3,
                        "port", Buffer() { 13, 0, 0, 0 },
                    },
                    "SS02", Package()    // USB2_3 Right rear (below Enter key)
                    {
                        "UsbConnector", 3,
                        "port", Buffer() { 14, 0, 0, 0 },
                    },
                    "SS03", Package()    // USB2_3 SD Card Reader (internal)
                    {
                        "UsbConnector", 255,
                        "port", Buffer() { 15, 0, 0, 0 },
                    },
                    "SS04", Package()    // USB2_3 Right front (below biometrics)
                    {
                        "UsbConnector", 3,
                        "port", Buffer() { 16, 0, 0, 0 },
                    },
                    "SS05", Package()    // USB-C
                    {
                        "UsbConnector", 3,
                        "port", Buffer() { 17, 0, 0, 0 },
                    },
                },
            },

        })
    }
}

//EOF
