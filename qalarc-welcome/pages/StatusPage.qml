import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami

Kirigami.ScrollablePage {
    title: "System Status"

    actions: [
        Kirigami.Action {
            text: "Refresh"
            icon.name: "view-refresh"
            onTriggered: systemBackend.updateStatus()
        }
    ]

    ColumnLayout {
        width: parent.width
        spacing: 20

        // Header
        Label {
            text: "System Status Dashboard"
            font.pointSize: 20
            font.bold: true
        }

        Label {
            text: "Monitor services, resources, and system health."
            wrapMode: Text.WordWrap
            Layout.fillWidth: true
        }

        // System Info Card
        Kirigami.Card {
            Layout.fillWidth: true

            header: RowLayout {
                Kirigami.Icon {
                    source: "computer"
                    Layout.preferredWidth: 32
                    Layout.preferredHeight: 32
                }

                Kirigami.Heading {
                    text: "System Information"
                    level: 2
                }
            }

            contentItem: GridLayout {
                columns: 2
                columnSpacing: 20
                rowSpacing: 10
                Layout.margins: 16

                Label {
                    text: "Hostname:"
                    font.bold: true
                }
                Label {
                    text: systemBackend.getHostname()
                }

                Label {
                    text: "Username:"
                    font.bold: true
                }
                Label {
                    text: systemBackend.getUsername()
                }

                Label {
                    text: "NixOS Generation:"
                    font.bold: true
                }
                Label {
                    text: systemBackend.generation
                }
            }
        }

        // Services Status
        Kirigami.Card {
            Layout.fillWidth: true

            header: RowLayout {
                Kirigami.Icon {
                    source: "services"
                    Layout.preferredWidth: 32
                    Layout.preferredHeight: 32
                }

                Kirigami.Heading {
                    text: "Services"
                    level: 2
                }
            }

            contentItem: ColumnLayout {
                Layout.margins: 16
                spacing: 15

                // Ollama Service
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 15

                    Rectangle {
                        width: 12
                        height: 12
                        radius: 6
                        color: systemBackend.ollamaRunning ? "#a6e3a1" : "#f38ba8"
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2

                        Label {
                            text: "Ollama Service"
                            font.bold: true
                        }

                        Label {
                            text: systemBackend.ollamaRunning ?
                                "Running on http://localhost:11434" :
                                "Not running"
                            font.pointSize: 10
                            color: systemBackend.ollamaRunning ? "#a6adc8" : "#f38ba8"
                        }
                    }

                    Button {
                        text: systemBackend.ollamaRunning ? "Restart" : "Start"
                        enabled: !systemBackend.ollamaRunning
                        onClicked: systemBackend.startOllama()
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    height: 1
                    color: "#45475a"
                }

                // Docker Service
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 15

                    Rectangle {
                        width: 12
                        height: 12
                        radius: 6
                        color: "#a6e3a1"  // Assume running (would need to check)
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2

                        Label {
                            text: "Docker Service"
                            font.bold: true
                        }

                        Label {
                            text: "Container platform enabled"
                            font.pointSize: 10
                            color: "#a6adc8"
                        }
                    }

                    Button {
                        text: "Open Lazydocker"
                        onClicked: Qt.openUrlExternally("konsole -e lazydocker")
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    height: 1
                    color: "#45475a"
                }

                // Open WebUI
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 15

                    Rectangle {
                        width: 12
                        height: 12
                        radius: 6
                        color: "#a6e3a1"
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2

                        Label {
                            text: "Open WebUI"
                            font.bold: true
                        }

                        Label {
                            text: "Web interface available"
                            font.pointSize: 10
                            color: "#a6adc8"
                        }
                    }

                    Button {
                        text: "Open in Browser"
                        onClicked: Qt.openUrlExternally("http://localhost:8080")
                    }
                }
            }
        }

        // Resource Usage
        Kirigami.Card {
            Layout.fillWidth: true

            header: RowLayout {
                Kirigami.Icon {
                    source: "dashboard-show"
                    Layout.preferredWidth: 32
                    Layout.preferredHeight: 32
                }

                Kirigami.Heading {
                    text: "Resource Usage"
                    level: 2
                }
            }

            contentItem: ColumnLayout {
                Layout.margins: 16
                spacing: 20

                // Disk Usage
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 5

                    RowLayout {
                        Label {
                            text: "Disk Usage"
                            font.bold: true
                        }

                        Label {
                            text: systemBackend.diskUsagePercent + "%"
                            color: systemBackend.diskUsagePercent > 80 ? "#f38ba8" :
                                   systemBackend.diskUsagePercent > 60 ? "#f9e2af" : "#a6e3a1"
                            font.bold: true
                        }
                    }

                    ProgressBar {
                        Layout.fillWidth: true
                        from: 0
                        to: 100
                        value: systemBackend.diskUsagePercent
                    }

                    Label {
                        text: systemBackend.diskUsagePercent > 80 ?
                            "⚠ Consider cleaning up old snapshots or models" :
                            "✓ Disk space healthy"
                        font.pointSize: 10
                        color: systemBackend.diskUsagePercent > 80 ? "#f9e2af" : "#a6e3a1"
                    }
                }

                // RAM Usage Placeholder
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 5

                    Label {
                        text: "RAM"
                        font.bold: true
                    }

                    Label {
                        text: "Total: " + hardware.ramTotalGB + "GB available for AI models"
                        font.pointSize: 10
                    }

                    Button {
                        text: "Monitor with btop"
                        onClicked: Qt.openUrlExternally("konsole -e btop")
                    }
                }

                // VRAM
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 5

                    Label {
                        text: "VRAM"
                        font.bold: true
                    }

                    Label {
                        text: "Allocated: " + hardware.vramGB + "GB for GPU compute"
                        font.pointSize: 10
                    }

                    Button {
                        text: "Monitor GPU (rocm-smi)"
                        onClicked: Qt.openUrlExternally("konsole -e watch -n 1 rocm-smi")
                    }
                }
            }
        }

        // Quick Actions
        Kirigami.Card {
            Layout.fillWidth: true

            header: Kirigami.Heading {
                text: "Quick Actions"
                level: 2
            }

            contentItem: GridLayout {
                Layout.margins: 16
                columns: 2
                rowSpacing: 10
                columnSpacing: 10

                Button {
                    text: "Open Terminal"
                    icon.name: "utilities-terminal"
                    Layout.fillWidth: true
                    onClicked: Qt.openUrlExternally("ghostty")
                }

                Button {
                    text: "Launch oterm"
                    icon.name: "ai-assistant"
                    Layout.fillWidth: true
                    onClicked: Qt.openUrlExternally("ghostty -e oterm")
                }

                Button {
                    text: "System Monitor (btop)"
                    icon.name: "utilities-system-monitor"
                    Layout.fillWidth: true
                    onClicked: Qt.openUrlExternally("konsole -e btop")
                }

                Button {
                    text: "GPU Monitor (nvtop)"
                    icon.name: "gpu"
                    Layout.fillWidth: true
                    onClicked: Qt.openUrlExternally("konsole -e nvtop")
                }

                Button {
                    text: "View Snapshots"
                    icon.name: "time-scheduler"
                    Layout.fillWidth: true
                    onClicked: Qt.openUrlExternally("konsole -e sudo snapper list")
                }

                Button {
                    text: "File Manager"
                    icon.name: "folder"
                    Layout.fillWidth: true
                    onClicked: Qt.openUrlExternally("dolphin")
                }
            }
        }

        // Installed Models (if any)
        Kirigami.Card {
            Layout.fillWidth: true

            header: Kirigami.Heading {
                text: "Downloaded Models"
                level: 2
            }

            contentItem: ColumnLayout {
                Layout.margins: 16
                spacing: 10

                Label {
                    text: "Check installed models and manage storage."
                    wrapMode: Text.WordWrap
                    Layout.fillWidth: true
                }

                Button {
                    text: "List Models (ollama list)"
                    icon.name: "view-list-details"
                    onClicked: Qt.openUrlExternally("konsole -e ollama list")
                }

                Button {
                    text: "Browse Model Folder"
                    icon.name: "folder-open"
                    onClicked: Qt.openUrlExternally("file://" + systemBackend.getUsername() + "/Models")
                }
            }
        }

        // Back button
        Button {
            text: "Back to Welcome"
            icon.name: "go-home"
            Layout.alignment: Qt.AlignHCenter
            Layout.topMargin: 20
            onClicked: pageStack.pop()
        }
    }
}
