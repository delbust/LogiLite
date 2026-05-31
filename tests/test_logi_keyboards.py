import unittest

from core.logi_keyboards import parse_system_profiler_keyboards


class LogitechKeyboardInventoryTests(unittest.TestCase):
    def test_parses_connected_mx_keys_from_bluetooth_system_profiler(self):
        output = """
Bluetooth:
    Devices (Paired, Configured, etc.):
        Connected:
            MX Keys M Mac:
                Address: D7:8F:9D:0B:2B:12
                Vendor ID: 0x046D
                Product ID: 0xB36A
                Firmware Version: RBK74.04_0016
                Minor Type: Keyboard
                Services: 0x400000 < BLE >
            MX Master 3S:
                Address: D7:A5:33:6D:88:8B
                Vendor ID: 0x046D
                Product ID: 0xB034
                Firmware Version: RBM22.01_0006
                Minor Type: Mouse
                Services: 0x400000 < BLE >
"""

        devices = parse_system_profiler_keyboards(output)

        self.assertEqual(len(devices), 1)
        self.assertEqual(devices[0].name, "MX Keys M Mac")
        self.assertEqual(devices[0].product_id, "0xB36A")
        self.assertEqual(devices[0].firmware_version, "RBK74.04_0016")
        self.assertEqual(devices[0].transport, "Bluetooth LE")
        self.assertTrue(devices[0].connected)

    def test_marks_bluetooth_not_connected_context(self):
        output = """
Bluetooth:
    Devices (Paired, Configured, etc.):
        Not Connected:
            MX Keys Mini:
                Address: 00:11:22:33:44:55
                Vendor ID: 0x046D
                Product ID: 0xB369
                Minor Type: Keyboard
"""

        devices = parse_system_profiler_keyboards(output)

        self.assertEqual(len(devices), 1)
        self.assertFalse(devices[0].connected)

    def test_ignores_non_logitech_keyboards(self):
        output = """
USB:
    Apple Keyboard:
        Product ID: 0x0267
        Vendor ID: 0x05ac
        Version: 0.69
"""

        self.assertEqual(parse_system_profiler_keyboards(output), [])


if __name__ == "__main__":
    unittest.main()
