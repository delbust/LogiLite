"""Logitech keyboard inventory helpers.

The mouse remapper already owns the active HID path for pointing devices.
Keyboard support starts as read-only device inventory so the app can surface
connected Logitech keyboards without changing key handling or permissions.
"""

from __future__ import annotations

from dataclasses import dataclass
import re
import subprocess
import sys


LOGITECH_VENDOR_ID = "0x046d"
_KEYBOARD_NAME_HINTS = (
    "keyboard",
    "keys",
    "k380",
    "k580",
    "k650",
    "k780",
    "k860",
    "craft",
    "ergo",
    "wave keys",
    "pop keys",
    "mx mechanical",
)


@dataclass(frozen=True)
class LogitechKeyboard:
    name: str
    vendor_id: str = ""
    product_id: str = ""
    firmware_version: str = ""
    transport: str = ""
    connected: bool = True

    def to_qml_dict(self) -> dict[str, object]:
        return {
            "name": self.name,
            "vendorId": self.vendor_id,
            "productId": self.product_id,
            "firmwareVersion": self.firmware_version,
            "transport": self.transport,
            "connected": self.connected,
        }


def _leading_spaces(line: str) -> int:
    return len(line) - len(line.lstrip(" "))


def _parse_property(line: str) -> tuple[str, str] | None:
    match = re.match(r"([^:]+):\s*(.*)$", line.strip())
    if not match:
        return None
    return match.group(1).strip(), match.group(2).strip()


def _is_keyboard_block(name: str, props: dict[str, str]) -> bool:
    minor_type = props.get("Minor Type", "").lower()
    if "keyboard" in minor_type:
        return True
    lowered_name = name.lower()
    return any(hint in lowered_name for hint in _KEYBOARD_NAME_HINTS)


def _transport_for_block(section: str, props: dict[str, str]) -> str:
    services = props.get("Services", "").upper()
    if "BLE" in services:
        return "Bluetooth LE"
    if props.get("Address"):
        return "Bluetooth"
    return section or "USB"


def _finalize_device(
    devices: list[LogitechKeyboard],
    *,
    name: str,
    props: dict[str, str],
    section: str,
    connected: bool,
) -> None:
    vendor_id = props.get("Vendor ID", "")
    if vendor_id.lower() != LOGITECH_VENDOR_ID:
        return
    if not _is_keyboard_block(name, props):
        return
    devices.append(
        LogitechKeyboard(
            name=name,
            vendor_id=vendor_id,
            product_id=props.get("Product ID", ""),
            firmware_version=props.get("Firmware Version", ""),
            transport=_transport_for_block(section, props),
            connected=connected,
        )
    )


def parse_system_profiler_keyboards(output: str) -> list[LogitechKeyboard]:
    """Parse macOS system_profiler Bluetooth/USB output for Logitech keyboards."""
    devices: list[LogitechKeyboard] = []
    section = ""
    connected_context = True
    current_name = ""
    current_props: dict[str, str] = {}
    current_indent = -1
    current_section = ""
    current_connected = True

    def flush_current() -> None:
        nonlocal current_name, current_props, current_indent
        if current_name:
            _finalize_device(
                devices,
                name=current_name,
                props=current_props,
                section=current_section,
                connected=current_connected,
            )
        current_name = ""
        current_props = {}
        current_indent = -1

    for raw_line in output.splitlines():
        if not raw_line.strip():
            continue
        stripped = raw_line.strip()
        indent = _leading_spaces(raw_line)

        if indent == 0 and stripped.endswith(":"):
            flush_current()
            top = stripped[:-1].strip()
            if top in {"Bluetooth", "USB"}:
                section = top
            continue

        if stripped in {"Connected:", "Not Connected:"}:
            flush_current()
            connected_context = stripped == "Connected:"
            continue

        if stripped.endswith(":") and ":" not in stripped[:-1]:
            flush_current()
            current_name = stripped[:-1].strip()
            current_indent = indent
            current_section = section
            current_connected = connected_context
            current_props = {}
            continue

        if current_name and indent > current_indent:
            prop = _parse_property(stripped)
            if prop:
                key, value = prop
                current_props[key] = value
            continue

        if current_name and indent <= current_indent:
            flush_current()

    flush_current()
    return devices


def get_logitech_keyboards(timeout: float = 8.0) -> list[dict[str, object]]:
    """Return connected Logitech keyboards as QML-friendly dictionaries."""
    if sys.platform != "darwin":
        return []
    try:
        result = subprocess.run(
            ["system_profiler", "SPBluetoothDataType", "SPUSBDataType"],
            check=False,
            capture_output=True,
            text=True,
            timeout=timeout,
        )
    except (OSError, subprocess.SubprocessError):
        return []
    if result.returncode != 0:
        return []
    return [device.to_qml_dict() for device in parse_system_profiler_keyboards(result.stdout)]
