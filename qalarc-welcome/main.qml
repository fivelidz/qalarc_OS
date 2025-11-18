import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami

Kirigami.ApplicationWindow {
    id: root
    title: "Welcome to qalarc_OS"
    width: 1000
    height: 700
    minimumWidth: 800
    minimumHeight: 600

    // Color scheme
    Kirigami.Theme.colorSet: Kirigami.Theme.Window

    pageStack.initialPage: welcomePage

    // Global header
    header: ToolBar {
        RowLayout {
            anchors.fill: parent

            Label {
                text: "qalarc_OS Welcome"
                font.pointSize: 16
                font.bold: true
                Layout.fillWidth: true
                Layout.leftMargin: 16
            }

            ToolButton {
                icon.name: "help-about"
                text: "About"
                display: AbstractButton.IconOnly
                onClicked: aboutDialog.open()
            }

            ToolButton {
                icon.name: "window-close"
                text: "Close"
                display: AbstractButton.IconOnly
                onClicked: {
                    controller.markWelcomeComplete()
                    Qt.quit()
                }
            }
        }
    }

    // Welcome/Navigation Page
    Component {
        id: welcomePage

        Kirigami.ScrollablePage {
            title: "Welcome"

            ColumnLayout {
                width: parent.width
                spacing: 30

                // Banner
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 200
                    gradient: Gradient {
                        GradientStop { position: 0.0; color: "#89b4fa" }  // Catppuccin blue
                        GradientStop { position: 1.0; color: "#b4befe" }  // Catppuccin lavender
                    }
                    radius: 10

                    ColumnLayout {
                        anchors.centerIn: parent
                        spacing: 10

                        Label {
                            text: "qalarc_OS"
                            font.pointSize: 32
                            font.bold: true
                            color: "#1e1e2e"  // Catppuccin base
                            Layout.alignment: Qt.AlignHCenter
                        }

                        Label {
                            text: "AI-Powered Workstation for AMD Hardware"
                            font.pointSize: 14
                            color: "#1e1e2e"
                            Layout.alignment: Qt.AlignHCenter
                        }

                        Label {
                            text: "Generation " + systemBackend.generation
                            font.pointSize: 10
                            color: "#585b70"  // Catppuccin surface2
                            Layout.alignment: Qt.AlignHCenter
                        }
                    }
                }

                // Welcome message
                Label {
                    text: "Welcome to your new qalarc_OS installation!"
                    font.pointSize: 18
                    font.bold: true
                    Layout.alignment: Qt.AlignHCenter
                }

                Label {
                    text: "This guide will help you verify your hardware, download AI models, and explore the system."
                    font.pointSize: 12
                    wrapMode: Text.WordWrap
                    Layout.fillWidth: true
                    Layout.leftMargin: 40
                    Layout.rightMargin: 40
                    Layout.alignment: Qt.AlignHCenter
                    horizontalAlignment: Text.AlignHCenter
                }

                // Navigation cards
                GridLayout {
                    Layout.fillWidth: true
                    Layout.leftMargin: 40
                    Layout.rightMargin: 40
                    columns: 2
                    rowSpacing: 20
                    columnSpacing: 20

                    // Hardware Verification Card
                    Button {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 120

                        background: Rectangle {
                            color: parent.hovered ? "#313244" : "#1e1e2e"
                            border.color: "#89b4fa"
                            border.width: 2
                            radius: 10
                        }

                        contentItem: ColumnLayout {
                            spacing: 10

                            Kirigami.Icon {
                                source: "computer"
                                Layout.preferredWidth: 48
                                Layout.preferredHeight: 48
                                Layout.alignment: Qt.AlignHCenter
                                color: "#89b4fa"
                            }

                            Label {
                                text: "Hardware Verification"
                                font.pointSize: 14
                                font.bold: true
                                Layout.alignment: Qt.AlignHCenter
                                color: "#cdd6f4"
                            }

                            Label {
                                text: "Check GPU, VRAM, and system specs"
                                font.pointSize: 10
                                Layout.alignment: Qt.AlignHCenter
                                color: "#a6adc8"
                            }
                        }

                        onClicked: pageStack.push(hardwarePageComponent)
                    }

                    // Model Download Card
                    Button {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 120

                        background: Rectangle {
                            color: parent.hovered ? "#313244" : "#1e1e2e"
                            border.color: "#a6e3a1"
                            border.width: 2
                            radius: 10
                        }

                        contentItem: ColumnLayout {
                            spacing: 10

                            Kirigami.Icon {
                                source: "download"
                                Layout.preferredWidth: 48
                                Layout.preferredHeight: 48
                                Layout.alignment: Qt.AlignHCenter
                                color: "#a6e3a1"
                            }

                            Label {
                                text: "Download AI Models"
                                font.pointSize: 14
                                font.bold: true
                                Layout.alignment: Qt.AlignHCenter
                                color: "#cdd6f4"
                            }

                            Label {
                                text: "Get started with LLMs"
                                font.pointSize: 10
                                Layout.alignment: Qt.AlignHCenter
                                color: "#a6adc8"
                            }
                        }

                        onClicked: pageStack.push(modelsPageComponent)
                    }

                    // Quick Tour Card
                    Button {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 120

                        background: Rectangle {
                            color: parent.hovered ? "#313244" : "#1e1e2e"
                            border.color: "#f9e2af"
                            border.width: 2
                            radius: 10
                        }

                        contentItem: ColumnLayout {
                            spacing: 10

                            Kirigami.Icon {
                                source: "help-about"
                                Layout.preferredWidth: 48
                                Layout.preferredHeight: 48
                                Layout.alignment: Qt.AlignHCenter
                                color: "#f9e2af"
                            }

                            Label {
                                text: "Quick Tour"
                                font.pointSize: 14
                                font.bold: true
                                Layout.alignment: Qt.AlignHCenter
                                color: "#cdd6f4"
                            }

                            Label {
                                text: "Learn about qalarc_OS features"
                                font.pointSize: 10
                                Layout.alignment: Qt.AlignHCenter
                                color: "#a6adc8"
                            }
                        }

                        onClicked: pageStack.push(tourPageComponent)
                    }

                    // System Status Card
                    Button {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 120

                        background: Rectangle {
                            color: parent.hovered ? "#313244" : "#1e1e2e"
                            border.color: "#cba6f7"
                            border.width: 2
                            radius: 10
                        }

                        contentItem: ColumnLayout {
                            spacing: 10

                            Kirigami.Icon {
                                source: "dashboard-show"
                                Layout.preferredWidth: 48
                                Layout.preferredHeight: 48
                                Layout.alignment: Qt.AlignHCenter
                                color: "#cba6f7"
                            }

                            Label {
                                text: "System Status"
                                font.pointSize: 14
                                font.bold: true
                                Layout.alignment: Qt.AlignHCenter
                                color: "#cdd6f4"
                            }

                            Label {
                                text: "Monitor services and resources"
                                font.pointSize: 10
                                Layout.alignment: Qt.AlignHCenter
                                color: "#a6adc8"
                            }
                        }

                        onClicked: pageStack.push(statusPageComponent)
                    }
                }

                // Skip button
                Button {
                    text: "Skip Welcome (Don't show again)"
                    Layout.alignment: Qt.AlignHCenter
                    Layout.topMargin: 20

                    onClicked: {
                        controller.markWelcomeComplete()
                        Qt.quit()
                    }
                }

                Item { Layout.fillHeight: true }
            }
        }
    }

    // Load page components
    Component {
        id: hardwarePageComponent
        HardwarePage {}
    }

    Component {
        id: modelsPageComponent
        ModelsPage {}
    }

    Component {
        id: tourPageComponent
        TourPage {}
    }

    Component {
        id: statusPageComponent
        StatusPage {}
    }

    // About Dialog
    Dialog {
        id: aboutDialog
        title: "About qalarc_OS"
        modal: true
        anchors.centerIn: parent
        width: 400

        ColumnLayout {
            spacing: 10

            Label {
                text: "qalarc_OS v1.0.0"
                font.pointSize: 16
                font.bold: true
            }

            Label {
                text: "AI-Powered Workstation Operating System"
                wrapMode: Text.WordWrap
            }

            Label {
                text: "Optimized for AMD Ryzen AI MAX+ processors\nwith integrated Radeon graphics and ROCm acceleration."
                wrapMode: Text.WordWrap
            }

            Label {
                text: "Built on NixOS for reproducible, declarative configuration."
                wrapMode: Text.WordWrap
            }
        }

        standardButtons: Dialog.Ok
    }
}
