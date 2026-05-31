import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Layouts
import "Theme.js" as Theme

Item {
    id: keyboardPage
    readonly property var theme: Theme.palette(uiState.darkMode)
    property var s: lm.strings

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
                height: 96

                Column {
                    anchors {
                        left: parent.left
                        leftMargin: 36
                        verticalCenter: parent.verticalCenter
                    }
                    spacing: 4

                    Text {
                        text: s["keyboard.title"] || "Keyboard"
                        font { family: uiState.fontFamily; pixelSize: 24; bold: true }
                        color: keyboardPage.theme.textPrimary
                    }

                    Text {
                        text: s["keyboard.subtitle"] || "Detected Logitech keyboards"
                        font { family: uiState.fontFamily; pixelSize: 13 }
                        color: keyboardPage.theme.textSecondary
                    }
                }

                Rectangle {
                    anchors {
                        right: parent.right
                        rightMargin: 36
                        verticalCenter: parent.verticalCenter
                    }
                    width: 42
                    height: 42
                    radius: 12
                    color: refreshMouse.containsMouse ? keyboardPage.theme.bgCardHover : keyboardPage.theme.bgCard
                    border.width: 1
                    border.color: keyboardPage.theme.border

                    AppIcon {
                        anchors.centerIn: parent
                        width: 18
                        height: 18
                        name: "refresh-cw"
                        iconColor: keyboardPage.theme.textPrimary
                    }

                    MouseArea {
                        id: refreshMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: backend.refreshKeyboardDevices()
                    }

                    ToolTip.visible: refreshMouse.containsMouse
                    ToolTip.text: s["keyboard.refresh"] || "Refresh"
                    Accessible.role: Accessible.Button
                    Accessible.name: s["keyboard.refresh"] || "Refresh"
                }
            }

            Rectangle {
                width: parent.width - 72
                height: 1
                color: keyboardPage.theme.border
                anchors.horizontalCenter: parent.horizontalCenter
            }

            Item { width: 1; height: 24 }

            Rectangle {
                width: parent.width - 72
                height: 96
                radius: 8
                color: keyboardPage.theme.bgCard
                border.width: 1
                border.color: keyboardPage.theme.border
                anchors.horizontalCenter: parent.horizontalCenter

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 22
                    spacing: 16

                    Rectangle {
                        Layout.preferredWidth: 48
                        Layout.preferredHeight: 48
                        radius: 8
                        color: keyboardPage.theme.accentDim

                        AppIcon {
                            anchors.centerIn: parent
                            width: 24
                            height: 24
                            name: "keyboard"
                            iconColor: keyboardPage.theme.accent
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 5

                        Text {
                            Layout.fillWidth: true
                            text: backend.keyboardConnected
                                  ? (backend.keyboardSummary || (s["keyboard.connected"] || "Keyboard connected"))
                                  : (s["keyboard.none"] || "No Logitech keyboard detected")
                            font { family: uiState.fontFamily; pixelSize: 18; bold: true }
                            color: keyboardPage.theme.textPrimary
                            elide: Text.ElideRight
                        }

                        Text {
                            Layout.fillWidth: true
                            text: backend.keyboardConnected
                                  ? (s["keyboard.status_ready"] || "Inventory ready")
                                  : (s["keyboard.status_empty"] || "Waiting for a Logitech keyboard")
                            font { family: uiState.fontFamily; pixelSize: 12 }
                            color: keyboardPage.theme.textSecondary
                            elide: Text.ElideRight
                        }
                    }
                }
            }

            Item { width: 1; height: 18 }

            Repeater {
                model: backend.keyboardDevices

                delegate: Rectangle {
                    width: pageScroll.availableWidth - 72
                    height: 118
                    radius: 8
                    color: keyboardPage.theme.bgCard
                    border.width: 1
                    border.color: keyboardPage.theme.border
                    anchors.horizontalCenter: parent.horizontalCenter

                    Column {
                        anchors {
                            fill: parent
                            margins: 20
                        }
                        spacing: 12

                        RowLayout {
                            width: parent.width
                            spacing: 12

                            Text {
                                Layout.fillWidth: true
                                text: modelData.name || "Logitech keyboard"
                                font { family: uiState.fontFamily; pixelSize: 17; bold: true }
                                color: keyboardPage.theme.textPrimary
                                elide: Text.ElideRight
                            }

                            Rectangle {
                                Layout.preferredWidth: stateText.implicitWidth + 18
                                Layout.preferredHeight: 28
                                radius: 8
                                color: modelData.connected ? keyboardPage.theme.accentDim : keyboardPage.theme.bgSubtle
                                border.width: 1
                                border.color: modelData.connected ? keyboardPage.theme.accent : keyboardPage.theme.border

                                Text {
                                    id: stateText
                                    anchors.centerIn: parent
                                    text: modelData.connected
                                          ? (s["keyboard.connected"] || "Connected")
                                          : (s["keyboard.not_connected"] || "Not connected")
                                    font { family: uiState.fontFamily; pixelSize: 11; bold: true }
                                    color: modelData.connected ? keyboardPage.theme.accent : keyboardPage.theme.textSecondary
                                }
                            }
                        }

                        GridLayout {
                            width: parent.width
                            columns: 4
                            columnSpacing: 14
                            rowSpacing: 8

                            Text {
                                text: s["keyboard.transport"] || "Transport"
                                font { family: uiState.fontFamily; pixelSize: 11; bold: true }
                                color: keyboardPage.theme.textDim
                            }
                            Text {
                                Layout.fillWidth: true
                                text: modelData.transport || "-"
                                font { family: uiState.fontFamily; pixelSize: 12 }
                                color: keyboardPage.theme.textPrimary
                                elide: Text.ElideRight
                            }
                            Text {
                                text: s["keyboard.product_id"] || "Product ID"
                                font { family: uiState.fontFamily; pixelSize: 11; bold: true }
                                color: keyboardPage.theme.textDim
                            }
                            Text {
                                Layout.fillWidth: true
                                text: modelData.productId || "-"
                                font { family: uiState.fontFamily; pixelSize: 12 }
                                color: keyboardPage.theme.textPrimary
                                elide: Text.ElideRight
                            }
                            Text {
                                text: s["keyboard.firmware"] || "Firmware"
                                font { family: uiState.fontFamily; pixelSize: 11; bold: true }
                                color: keyboardPage.theme.textDim
                            }
                            Text {
                                Layout.fillWidth: true
                                text: modelData.firmwareVersion || "-"
                                font { family: uiState.fontFamily; pixelSize: 12 }
                                color: keyboardPage.theme.textPrimary
                                elide: Text.ElideRight
                            }
                            Text {
                                text: s["keyboard.vendor_id"] || "Vendor ID"
                                font { family: uiState.fontFamily; pixelSize: 11; bold: true }
                                color: keyboardPage.theme.textDim
                            }
                            Text {
                                Layout.fillWidth: true
                                text: modelData.vendorId || "-"
                                font { family: uiState.fontFamily; pixelSize: 12 }
                                color: keyboardPage.theme.textPrimary
                                elide: Text.ElideRight
                            }
                        }
                    }
                }
            }

            Item { width: 1; height: 28 }
        }
    }
}
