import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami

Kirigami.ScrollablePage {
    title: "Hardware Verification"

    actions: [
        Kirigami.Action {
            text: "Refresh"
            icon.name: "view-refresh"
            onTriggered: hardware.detectHardware()
        }
    ]

    ColumnLayout {
        width: parent.width
        spacing: 20

        // Header
        Label {
            text: "System Hardware Status"
            font.pointSize: 20
            font.bold: true
        }

        Label {
            text: "Verify that your hardware is correctly detected and configured for AI workloads."
            wrapMode: Text.WordWrap
            Layout.fillWidth: true
        }

        // CPU Card
        Kirigami.Card {
            Layout.fillWidth: true

            header: RowLayout {
                Kirigami.Icon {
                    source: "cpu"
                    Layout.preferredWidth: 32
                    Layout.preferredHeight: 32
                }

                Kirigami.Heading {
                    text: "CPU"
                    level: 2
                }
            }

            contentItem: ColumnLayout {
                spacing: 10
                Layout.margins: 16

                Label {
                    text: "Model: " + hardware.cpuModel
                    wrapMode: Text.WordWrap
                    Layout.fillWidth: true
                }

                Label {
                    text: hardware.cpuModel.includes("Ryzen") && hardware.cpuModel.includes("AI") ?
                        "✓ AMD Ryzen AI MAX+ detected - Excellent for AI workloads!" :
                        "AMD CPU detected"
                    color: hardware.cpuModel.includes("Ryzen") && hardware.cpuModel.includes("AI") ?
                        "#a6e3a1" : "#f9e2af"
                    font.bold: true
                }
            }
        }

        // GPU Card
        Kirigami.Card {
            Layout.fillWidth: true

            header: RowLayout {
                Kirigami.Icon {
                    source: "video-display"
                    Layout.preferredWidth: 32
                    Layout.preferredHeight: 32
                }

                Kirigami.Heading {
                    text: "GPU"
                    level: 2
                }
            }

            contentItem: ColumnLayout {
                spacing: 10
                Layout.margins: 16

                Label {
                    text: "Model: " + hardware.gpuModel
                    wrapMode: Text.WordWrap
                    Layout.fillWidth: true
                }

                Label {
                    text: hardware.gpuModel.includes("AMD") ?
                        "✓ AMD GPU detected - ROCm acceleration available" :
                        "⚠ Non-AMD GPU detected - limited AI acceleration"
                    color: hardware.gpuModel.includes("AMD") ? "#a6e3a1" : "#f9e2af"
                    font.bold: true
                }
            }
        }

        // RAM Card
        Kirigami.Card {
            Layout.fillWidth: true

            header: RowLayout {
                Kirigami.Icon {
                    source: "memory"
                    Layout.preferredWidth: 32
                    Layout.preferredHeight: 32
                }

                Kirigami.Heading {
                    text: "System RAM"
                    level: 2
                }
            }

            contentItem: ColumnLayout {
                spacing: 10
                Layout.margins: 16

                Label {
                    text: "Total: " + hardware.ramTotalGB + " GB"
                    font.pointSize: 14
                    font.bold: true
                }

                Label {
                    text: hardware.ramTotalGB >= 64 ?
                        "✓ Excellent - Sufficient for large AI models" :
                        hardware.ramTotalGB >= 32 ?
                        "⚠ Good - May limit very large models" :
                        "⚠ Limited - Consider RAM upgrade for AI workloads"
                    color: hardware.ramTotalGB >= 64 ? "#a6e3a1" :
                           hardware.ramTotalGB >= 32 ? "#f9e2af" : "#f38ba8"
                }
            }
        }

        // VRAM Card (Most Important!)
        Kirigami.Card {
            Layout.fillWidth: true

            header: RowLayout {
                Kirigami.Icon {
                    source: "gpu"
                    Layout.preferredWidth: 32
                    Layout.preferredHeight: 32
                    color: hardware.vramStatus === "excellent" ? "#a6e3a1" :
                           hardware.vramStatus === "good" ? "#f9e2af" : "#f38ba8"
                }

                Kirigami.Heading {
                    text: "VRAM Allocation"
                    level: 2
                }
            }

            contentItem: ColumnLayout {
                spacing: 15
                Layout.margins: 16

                Label {
                    text: "Allocated: " + hardware.vramGB + " GB"
                    font.pointSize: 18
                    font.bold: true
                    color: hardware.vramStatus === "excellent" ? "#a6e3a1" :
                           hardware.vramStatus === "good" ? "#f9e2af" : "#f38ba8"
                }

                Label {
                    text: hardware.vramRecommendation
                    wrapMode: Text.WordWrap
                    Layout.fillWidth: true
                    font.bold: true
                }

                // Status indicator
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 80
                    color: hardware.vramStatus === "excellent" ? "#a6e3a133" :
                           hardware.vramStatus === "good" ? "#f9e2af33" : "#f38ba833"
                    radius: 8

                    ColumnLayout {
                        anchors.centerIn: parent
                        spacing: 5

                        Label {
                            text: hardware.vramStatus === "excellent" ? "✓ Optimal Configuration" :
                                  hardware.vramStatus === "good" ? "⚠ Good, Can Improve" :
                                  "⚠ Configuration Needed"
                            font.pointSize: 14
                            font.bold: true
                            Layout.alignment: Qt.AlignHCenter
                        }

                        Label {
                            text: hardware.vramStatus === "excellent" ?
                                "You can run 70B+ parameter models" :
                                hardware.vramStatus === "good" ?
                                "You can run up to 70B models, consider BIOS update for more" :
                                "See BIOS setup guide in ~/Documents/qalarc-os-setup/"
                            font.pointSize: 10
                            Layout.alignment: Qt.AlignHCenter
                        }
                    }
                }

                // BIOS Guide button (if needed)
                Button {
                    text: "View BIOS Setup Guide"
                    Layout.alignment: Qt.AlignHCenter
                    visible: hardware.vramGB < 90

                    onClicked: {
                        Qt.openUrlExternally("file://" + systemBackend.getUsername() + "/Documents/qalarc-os-setup/BIOS-SETUP-GUIDE.md")
                    }
                }
            }
        }

        // Overall Status
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 100
            color: hardware.compatible ? "#a6e3a133" : "#f9e2af33"
            radius: 10

            ColumnLayout {
                anchors.centerIn: parent
                spacing: 10

                Label {
                    text: hardware.compatible ?
                        "✓ System Ready for AI Workloads" :
                        "⚠ Some Components May Limit Performance"
                    font.pointSize: 16
                    font.bold: true
                    Layout.alignment: Qt.AlignHCenter
                }

                Label {
                    text: hardware.compatible ?
                        "Your hardware is optimally configured for qalarc_OS" :
                        "Review recommendations above to improve performance"
                    font.pointSize: 11
                    Layout.alignment: Qt.AlignHCenter
                }
            }
        }

        // Actions
        RowLayout {
            Layout.alignment: Qt.AlignHCenter
            Layout.topMargin: 20
            spacing: 10

            Button {
                text: "Refresh Detection"
                icon.name: "view-refresh"
                onClicked: hardware.detectHardware()
            }

            Button {
                text: "Continue to Models"
                icon.name: "go-next"
                highlighted: true
                onClicked: pageStack.push(modelsPageComponent)
            }
        }
    }

    Component {
        id: modelsPageComponent
        ModelsPage {}
    }
}
