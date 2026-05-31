import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Layouts
import "Theme.js" as Theme

Item {
    id: keyboardPage
    readonly property var theme: Theme.palette(uiState.darkMode)
    property var s: lm.strings
    readonly property int pageMargin: 36
    readonly property int availableCardWidth: Math.max(320, width - pageMargin * 2)

    function tr(key, fallback) {
        return s[key] || fallback
    }

    function driverAction(actionId) {
        if (actionId === "keyboard")
            backend.openKeyboardSettings()
        else if (actionId === "bluetooth")
            backend.openBluetoothSettings()
        else if (actionId === "karabiner")
            backend.openKarabinerPage()
        else if (actionId === "options")
            backend.openLogiOptionsPage()
        else if (actionId === "ghub")
            backend.openLogitechGHubPage()
        else if (actionId === "solaar")
            backend.openSolaarPage()
        else if (actionId === "logiops")
            backend.openLogiopsPage()
        else if (actionId === "copy")
            backend.copyKeyboardInventory()
        else
            backend.refreshKeyboardDevices()
    }

    component StatusPill: Rectangle {
        property string label: ""
        property color dotColor: keyboardPage.theme.accent

        Layout.preferredWidth: pillText.implicitWidth + 30
        Layout.preferredHeight: 28
        radius: 8
        color: Qt.rgba(1, 1, 1, uiState.darkMode ? 0.055 : 0.86)
        border.width: 1
        border.color: keyboardPage.theme.border

        Row {
            anchors.centerIn: parent
            spacing: 8

            Rectangle {
                width: 7
                height: 7
                radius: 4
                anchors.verticalCenter: parent.verticalCenter
                color: dotColor
            }

            Text {
                id: pillText
                anchors.verticalCenter: parent.verticalCenter
                text: label
                font { family: uiState.fontFamily; pixelSize: 11; bold: true }
                color: keyboardPage.theme.textSecondary
            }
        }
    }

    component IconButton: Rectangle {
        property string iconName: "refresh-cw"
        property string tooltip: ""
        signal triggered()

        Layout.preferredWidth: 42
        Layout.preferredHeight: 42
        radius: 10
        color: iconButtonMouse.containsMouse ? keyboardPage.theme.bgCardHover : keyboardPage.theme.bgCard
        border.width: 1
        border.color: keyboardPage.theme.border

        AppIcon {
            anchors.centerIn: parent
            width: 18
            height: 18
            name: iconName
            iconColor: keyboardPage.theme.textPrimary
        }

        MouseArea {
            id: iconButtonMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: triggered()
        }

        ToolTip.visible: iconButtonMouse.containsMouse && tooltip !== ""
        ToolTip.text: tooltip
        Accessible.role: Accessible.Button
        Accessible.name: tooltip
    }

    component ActionTile: Rectangle {
        property string iconName: "keyboard"
        property string title: ""
        property string subtitle: ""
        property string actionId: ""
        property bool primary: false

        Layout.fillWidth: true
        Layout.preferredHeight: 96
        radius: 8
        color: tileMouse.containsMouse
               ? (primary ? keyboardPage.theme.accentHover : keyboardPage.theme.bgCardHover)
               : (primary ? keyboardPage.theme.accent : keyboardPage.theme.bgCard)
        border.width: primary ? 0 : 1
        border.color: keyboardPage.theme.border

        Behavior on color { ColorAnimation { duration: 140 } }

        RowLayout {
            anchors.fill: parent
            anchors.margins: 18
            spacing: 14

            Rectangle {
                Layout.preferredWidth: 40
                Layout.preferredHeight: 40
                radius: 9
                color: primary
                       ? Qt.rgba(1, 1, 1, 0.16)
                       : keyboardPage.theme.accentDim

                AppIcon {
                    anchors.centerIn: parent
                    width: 20
                    height: 20
                    name: iconName
                    iconColor: primary ? "#ffffff" : keyboardPage.theme.accent
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 4

                Text {
                    Layout.fillWidth: true
                    text: title
                    font { family: uiState.fontFamily; pixelSize: 13; bold: true }
                    color: primary ? "#ffffff" : keyboardPage.theme.textPrimary
                    elide: Text.ElideRight
                }

                Text {
                    Layout.fillWidth: true
                    text: subtitle
                    font { family: uiState.fontFamily; pixelSize: 11 }
                    color: primary ? Qt.rgba(1, 1, 1, 0.78) : keyboardPage.theme.textSecondary
                    elide: Text.ElideRight
                }
            }
        }

        MouseArea {
            id: tileMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: keyboardPage.driverAction(actionId)
        }

        Accessible.role: Accessible.Button
        Accessible.name: title
    }

    component MetricLabel: ColumnLayout {
        property string label: ""
        property string value: ""

        spacing: 4

        Text {
            Layout.fillWidth: true
            text: label
            font { family: uiState.fontFamily; pixelSize: 10; bold: true }
            color: keyboardPage.theme.textDim
            elide: Text.ElideRight
        }

        Text {
            Layout.fillWidth: true
            text: value || "-"
            font { family: uiState.fontFamily; pixelSize: 13 }
            color: keyboardPage.theme.textPrimary
            elide: Text.ElideRight
        }
    }

    ScrollView {
        id: pageScroll
        anchors.fill: parent
        clip: true
        contentWidth: availableWidth

        Column {
            width: pageScroll.availableWidth
            spacing: 0

            Item {
                width: parent.width
                height: 150

                ColumnLayout {
                    anchors {
                        left: parent.left
                        leftMargin: keyboardPage.pageMargin
                        right: headerActions.left
                        rightMargin: 22
                        verticalCenter: parent.verticalCenter
                    }
                    spacing: 10

                    Text {
                        Layout.fillWidth: true
                        text: keyboardPage.tr("keyboard.title", "Keyboard Studio")
                        font { family: uiState.fontFamily; pixelSize: 26; bold: true }
                        color: keyboardPage.theme.textPrimary
                        elide: Text.ElideRight
                    }

                    Text {
                        Layout.fillWidth: true
                        text: keyboardPage.tr("keyboard.subtitle", "Logitech keyboard control surface")
                        font { family: uiState.fontFamily; pixelSize: 13 }
                        color: keyboardPage.theme.textSecondary
                        elide: Text.ElideRight
                    }

                    RowLayout {
                        spacing: 8

                        StatusPill {
                            label: backend.keyboardConnected
                                   ? keyboardPage.tr("keyboard.connected", "Connected")
                                   : keyboardPage.tr("keyboard.none", "No keyboard")
                            dotColor: backend.keyboardConnected ? keyboardPage.theme.accent : keyboardPage.theme.textDim
                        }

                        StatusPill {
                            label: backend.keyboardConnectedCount + " " + keyboardPage.tr("keyboard.devices", "devices")
                            dotColor: keyboardPage.theme.success
                        }

                        StatusPill {
                            label: Qt.platform.os === "osx" ? "macOS" : Qt.platform.os
                            dotColor: keyboardPage.theme.warning
                        }
                    }
                }

                RowLayout {
                    id: headerActions
                    anchors {
                        right: parent.right
                        rightMargin: keyboardPage.pageMargin
                        verticalCenter: parent.verticalCenter
                    }
                    spacing: 10

                    IconButton {
                        iconName: "refresh-cw"
                        tooltip: keyboardPage.tr("keyboard.refresh", "Refresh")
                        onTriggered: backend.refreshKeyboardDevices()
                    }

                    IconButton {
                        iconName: "info"
                        tooltip: keyboardPage.tr("keyboard.copy_inventory", "Copy inventory")
                        onTriggered: backend.copyKeyboardInventory()
                    }
                }
            }

            Rectangle {
                width: parent.width - keyboardPage.pageMargin * 2
                height: 1
                color: keyboardPage.theme.border
                anchors.horizontalCenter: parent.horizontalCenter
            }

            Item { width: 1; height: 24 }

            GridLayout {
                width: parent.width - keyboardPage.pageMargin * 2
                anchors.horizontalCenter: parent.horizontalCenter
                columns: width > 760 ? 4 : 2
                columnSpacing: 12
                rowSpacing: 12

                ActionTile {
                    iconName: "keyboard"
                    title: keyboardPage.tr("keyboard.action_keyboard_settings", "macOS Keyboard")
                    subtitle: keyboardPage.tr("keyboard.action_keyboard_settings_desc", "Keys, repeat, shortcuts")
                    actionId: "keyboard"
                    primary: true
                }

                ActionTile {
                    iconName: "sliders-horizontal"
                    title: "Karabiner"
                    subtitle: keyboardPage.tr("keyboard.action_karabiner_desc", "Device-specific remaps")
                    actionId: "karabiner"
                }

                ActionTile {
                    iconName: "mouse-simple"
                    title: "Logi Options+"
                    subtitle: keyboardPage.tr("keyboard.action_options_desc", "Official Logitech stack")
                    actionId: "options"
                }

                ActionTile {
                    iconName: "keyboard"
                    title: "G HUB"
                    subtitle: keyboardPage.tr("keyboard.action_ghub_desc", "Gaming keyboard stack")
                    actionId: "ghub"
                }
            }

            Item { width: 1; height: 26 }

            RowLayout {
                width: parent.width - keyboardPage.pageMargin * 2
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 12

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2

                    Text {
                        Layout.fillWidth: true
                        text: keyboardPage.tr("keyboard.devices_title", "Devices")
                        font { family: uiState.fontFamily; pixelSize: 18; bold: true }
                        color: keyboardPage.theme.textPrimary
                        elide: Text.ElideRight
                    }

                    Text {
                        Layout.fillWidth: true
                        text: backend.keyboardSummary || keyboardPage.tr("keyboard.status_empty", "Waiting for a Logitech keyboard")
                        font { family: uiState.fontFamily; pixelSize: 12 }
                        color: keyboardPage.theme.textSecondary
                        elide: Text.ElideRight
                    }
                }

                IconButton {
                    iconName: "refresh-cw"
                    tooltip: keyboardPage.tr("keyboard.refresh", "Refresh")
                    onTriggered: backend.refreshKeyboardDevices()
                }
            }

            Item { width: 1; height: 14 }

            Rectangle {
                width: parent.width - keyboardPage.pageMargin * 2
                height: 156
                radius: 8
                color: keyboardPage.theme.bgCard
                border.width: 1
                border.color: keyboardPage.theme.border
                anchors.horizontalCenter: parent.horizontalCenter
                visible: !backend.keyboardConnected

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 24
                    spacing: 18

                    Rectangle {
                        Layout.preferredWidth: 54
                        Layout.preferredHeight: 54
                        radius: 12
                        color: keyboardPage.theme.accentDim

                        AppIcon {
                            anchors.centerIn: parent
                            width: 28
                            height: 28
                            name: "keyboard"
                            iconColor: keyboardPage.theme.accent
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 5

                        Text {
                            Layout.fillWidth: true
                            text: keyboardPage.tr("keyboard.none", "No Logitech keyboard detected")
                            font { family: uiState.fontFamily; pixelSize: 18; bold: true }
                            color: keyboardPage.theme.textPrimary
                            elide: Text.ElideRight
                        }

                        Text {
                            Layout.fillWidth: true
                            text: keyboardPage.tr("keyboard.empty_hint", "Connect by Bluetooth, Bolt, Unifying, or USB.")
                            font { family: uiState.fontFamily; pixelSize: 12 }
                            color: keyboardPage.theme.textSecondary
                            elide: Text.ElideRight
                        }
                    }

                    ActionTile {
                        Layout.preferredWidth: 190
                        Layout.fillWidth: false
                        iconName: "refresh-cw"
                        title: keyboardPage.tr("keyboard.refresh", "Refresh")
                        subtitle: keyboardPage.tr("keyboard.action_refresh_desc", "Scan now")
                        actionId: "refresh"
                    }
                }
            }

            Repeater {
                model: backend.keyboardDevices

                delegate: Rectangle {
                    width: pageScroll.availableWidth - keyboardPage.pageMargin * 2
                    height: 160
                    radius: 8
                    color: deviceMouse.containsMouse ? keyboardPage.theme.bgCardHover : keyboardPage.theme.bgCard
                    border.width: 1
                    border.color: keyboardPage.theme.border
                    anchors.horizontalCenter: parent.horizontalCenter

                    Behavior on color { ColorAnimation { duration: 140 } }

                    MouseArea {
                        id: deviceMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        acceptedButtons: Qt.NoButton
                    }

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 22
                        spacing: 18

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 14

                            Rectangle {
                                Layout.preferredWidth: 46
                                Layout.preferredHeight: 46
                                radius: 10
                                color: modelData.connected ? keyboardPage.theme.accentDim : keyboardPage.theme.bgSubtle

                                AppIcon {
                                    anchors.centerIn: parent
                                    width: 24
                                    height: 24
                                    name: "keyboard"
                                    iconColor: modelData.connected ? keyboardPage.theme.accent : keyboardPage.theme.textDim
                                }
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 4

                                Text {
                                    Layout.fillWidth: true
                                    text: modelData.name || "Logitech keyboard"
                                    font { family: uiState.fontFamily; pixelSize: 17; bold: true }
                                    color: keyboardPage.theme.textPrimary
                                    elide: Text.ElideRight
                                }

                                Text {
                                    Layout.fillWidth: true
                                    text: modelData.connected
                                          ? keyboardPage.tr("keyboard.status_ready", "Inventory ready")
                                          : keyboardPage.tr("keyboard.not_connected", "Not connected")
                                    font { family: uiState.fontFamily; pixelSize: 12 }
                                    color: keyboardPage.theme.textSecondary
                                    elide: Text.ElideRight
                                }
                            }

                            StatusPill {
                                label: modelData.connected
                                       ? keyboardPage.tr("keyboard.connected", "Connected")
                                       : keyboardPage.tr("keyboard.not_connected", "Not connected")
                                dotColor: modelData.connected ? keyboardPage.theme.accent : keyboardPage.theme.textDim
                            }
                        }

                        GridLayout {
                            Layout.fillWidth: true
                            columns: 4
                            columnSpacing: 20
                            rowSpacing: 8

                            MetricLabel {
                                Layout.fillWidth: true
                                label: keyboardPage.tr("keyboard.transport", "Transport")
                                value: modelData.transport || "-"
                            }

                            MetricLabel {
                                Layout.fillWidth: true
                                label: keyboardPage.tr("keyboard.product_id", "Product ID")
                                value: modelData.productId || "-"
                            }

                            MetricLabel {
                                Layout.fillWidth: true
                                label: keyboardPage.tr("keyboard.firmware", "Firmware")
                                value: modelData.firmwareVersion || "-"
                            }

                            MetricLabel {
                                Layout.fillWidth: true
                                label: keyboardPage.tr("keyboard.vendor_id", "Vendor ID")
                                value: modelData.vendorId || "-"
                            }
                        }
                    }
                }
            }

            Item { width: 1; height: 28 }

            RowLayout {
                width: parent.width - keyboardPage.pageMargin * 2
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 12

                Text {
                    Layout.fillWidth: true
                    text: keyboardPage.tr("keyboard.driver_stack", "Driver Stack")
                    font { family: uiState.fontFamily; pixelSize: 18; bold: true }
                    color: keyboardPage.theme.textPrimary
                    elide: Text.ElideRight
                }

                StatusPill {
                    label: "HID++"
                    dotColor: keyboardPage.theme.accent
                }
            }

            Item { width: 1; height: 14 }

            GridLayout {
                width: parent.width - keyboardPage.pageMargin * 2
                anchors.horizontalCenter: parent.horizontalCenter
                columns: width > 760 ? 4 : 2
                columnSpacing: 12
                rowSpacing: 12

                ActionTile {
                    iconName: "sliders-horizontal"
                    title: keyboardPage.tr("keyboard.action_bluetooth", "Bluetooth")
                    subtitle: keyboardPage.tr("keyboard.action_bluetooth_desc", "Pairing and battery")
                    actionId: "bluetooth"
                }

                ActionTile {
                    iconName: "info"
                    title: keyboardPage.tr("keyboard.action_copy", "Copy JSON")
                    subtitle: keyboardPage.tr("keyboard.action_copy_desc", "Inventory snapshot")
                    actionId: "copy"
                }

                ActionTile {
                    iconName: "keyboard"
                    title: "Solaar"
                    subtitle: keyboardPage.tr("keyboard.action_solaar_desc", "Linux Logitech manager")
                    actionId: "solaar"
                }

                ActionTile {
                    iconName: "mouse-simple"
                    title: "logiops"
                    subtitle: keyboardPage.tr("keyboard.action_logiops_desc", "Linux HID++ driver")
                    actionId: "logiops"
                }
            }

            Item { width: 1; height: 34 }
        }
    }
}
