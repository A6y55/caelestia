pragma ComponentBehavior: Bound

import ".."
import "../components"
import QtQuick
import QtQuick.Layouts
import Quickshell.Widgets
import Caelestia.Config
import qs.components
import qs.components.containers
import qs.components.controls
import qs.components.effects
import qs.services

Item {
    id: root

    required property Session session

    anchors.fill: parent

    ClippingRectangle {
        anchors.fill: parent
        anchors.margins: Tokens.padding.normal
        anchors.leftMargin: 0
        anchors.rightMargin: Tokens.padding.normal

        radius: border.innerRadius
        color: "transparent"

        Loader {
            anchors.fill: parent
            anchors.margins: Tokens.padding.large + Tokens.padding.normal
            anchors.leftMargin: Tokens.padding.large
            anchors.rightMargin: Tokens.padding.large

            asynchronous: true
            sourceComponent: contentComponent
        }
    }

    InnerBorder {
        id: border

        leftThickness: 0
        rightThickness: Tokens.padding.normal
    }

    Component {
        id: contentComponent

        StyledFlickable {
            id: flickable

            contentHeight: layout.height
            flickableDirection: Flickable.VerticalFlick

            StyledScrollBar.vertical: StyledScrollBar {
                flickable: flickable
            }

            ColumnLayout {
                id: layout

                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                spacing: Tokens.spacing.normal

                RowLayout {
                    spacing: Tokens.spacing.smaller

                    StyledText {
                        text: qsTr("Wallpaper")
                        font.pointSize: Tokens.font.size.large
                        font.weight: 500
                    }
                }

                SectionContainer {
                    Layout.fillWidth: true
                    alignTop: true

                    StyledText {
                        text: qsTr("Wallpaper Engine")
                        font.pointSize: Tokens.font.size.normal
                    }

                    SwitchRow {
                        label: qsTr("Dynamic wallpaper enabled")
                        checked: WallpaperEngine.enabled
                        onToggled: checked => WallpaperEngine.setEnabled(checked)
                    }

                    SwitchRow {
                        label: qsTr("Start dynamic wallpaper on login")
                        checked: WallpaperEngine.autostart
                        enabled: WallpaperEngine.enabled
                        onToggled: checked => WallpaperEngine.setAutostart(checked)
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: Tokens.spacing.normal

                        IconTextButton {
                            icon: "restore"
                            text: qsTr("Restore current")
                            type: IconTextButton.Tonal
                            onClicked: WallpaperEngine.restoreCurrent()
                        }

                        IconTextButton {
                            icon: "skip_next"
                            text: qsTr("Next wallpaper")
                            type: IconTextButton.Tonal
                            onClicked: WallpaperEngine.nextWallpaper()
                        }

                        Item {
                            Layout.fillWidth: true
                        }
                    }
                }

                SectionContainer {
                    Layout.fillWidth: true
                    alignTop: true

                    StyledText {
                        text: qsTr("Timed Switching")
                        font.pointSize: Tokens.font.size.normal
                    }

                    SwitchRow {
                        label: qsTr("Enabled")
                        checked: WallpaperEngine.randomSwitchEnabled
                        enabled: WallpaperEngine.enabled
                        onToggled: checked => WallpaperEngine.setRandomSwitchEnabled(checked)
                    }

                    SliderInput {
                        Layout.fillWidth: true

                        label: qsTr("Interval")
                        value: WallpaperEngine.randomSwitchIntervalMinutes
                        enabled: WallpaperEngine.enabled && WallpaperEngine.randomSwitchEnabled
                        from: 1
                        to: 240
                        stepSize: 1
                        suffix: "min"
                        validator: IntValidator {
                            bottom: 1
                            top: 240
                        }
                        formatValueFunction: val => Math.round(val).toString()
                        parseValueFunction: text => parseInt(text)

                        onValueModified: newValue => WallpaperEngine.setRandomSwitchIntervalMinutes(Math.round(newValue))
                    }
                }

                Loader {
                    Layout.fillWidth: true
                    active: WallpaperEngine.status !== ""
                    visible: active

                    sourceComponent: StyledText {
                        text: WallpaperEngine.status
                        color: Colours.palette.m3outline
                    }
                }
            }
        }
    }
}
