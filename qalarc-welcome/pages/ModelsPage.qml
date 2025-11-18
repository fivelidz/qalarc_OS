import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami

Kirigami.ScrollablePage {
    title: "AI Model Download Wizard"

    actions: [
        Kirigami.Action {
            text: "Refresh"
            icon.name: "view-refresh"
            onTriggered: models.loadModels()
        }
    ]

    ColumnLayout {
        width: parent.width
        spacing: 20

        // Header
        Label {
            text: "Download AI Models"
            font.pointSize: 20
            font.bold: true
        }

        Label {
            text: "Select models to download based on your VRAM and use case. Models are downloaded using Ollama."
            wrapMode: Text.WordWrap
            Layout.fillWidth: true
        }

        // VRAM Info Card
        Kirigami.Card {
            Layout.fillWidth: true

            header: RowLayout {
                Kirigami.Icon {
                    source: "gpu"
                    Layout.preferredWidth: 32
                    Layout.preferredHeight: 32
                }

                Kirigami.Heading {
                    text: "Available VRAM: " + hardware.vramGB + " GB"
                    level: 2
                }
            }

            contentItem: ColumnLayout {
                Layout.margins: 16
                spacing: 10

                Label {
                    text: hardware.vramGB >= 90 ?
                        "You can run large 70B+ parameter models!" :
                        hardware.vramGB >= 60 ?
                        "You can run up to 70B parameter models" :
                        hardware.vramGB >= 30 ?
                        "Recommended: Models up to 30B parameters" :
                        "Recommended: Smaller models (3B-7B parameters)"
                    font.bold: true
                }

                Button {
                    text: "Check Hardware"
                    icon.name: "computer"
                    onClicked: pageStack.push(hardwarePageComponent)
                }
            }
        }

        // Model Categories
        Kirigami.Heading {
            text: "Recommended Models"
            level: 3
        }

        // 70B Models (if VRAM >= 90GB)
        Kirigami.Card {
            Layout.fillWidth: true
            visible: hardware.vramGB >= 90

            header: Kirigami.Heading {
                text: "Large Models (70B+) - Best Quality"
                level: 3
            }

            contentItem: ColumnLayout {
                Layout.margins: 16
                spacing: 15

                // Llama 3.3 70B
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 15

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 5

                        Label {
                            text: "Llama 3.3 70B"
                            font.pointSize: 14
                            font.bold: true
                        }

                        Label {
                            text: "Meta's flagship model - Excellent for general tasks, reasoning, and chat"
                            wrapMode: Text.WordWrap
                            font.pointSize: 10
                            Layout.fillWidth: true
                        }

                        Label {
                            text: "Size: ~40GB | VRAM: 70GB required"
                            font.pointSize: 9
                            color: "#a6adc8"
                        }
                    }

                    Button {
                        text: models.isModelInstalled("llama3.3:70b") ? "Installed" : "Download"
                        enabled: !models.isModelInstalled("llama3.3:70b")
                        highlighted: !models.isModelInstalled("llama3.3:70b")
                        onClicked: models.downloadModel("llama3.3:70b")
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    height: 1
                    color: "#45475a"
                }

                // Qwen 2.5 72B
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 15

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 5

                        Label {
                            text: "Qwen 2.5 72B"
                            font.pointSize: 14
                            font.bold: true
                        }

                        Label {
                            text: "Latest Qwen model - Strong multilingual support and reasoning"
                            wrapMode: Text.WordWrap
                            font.pointSize: 10
                            Layout.fillWidth: true
                        }

                        Label {
                            text: "Size: ~41GB | VRAM: 72GB required"
                            font.pointSize: 9
                            color: "#a6adc8"
                        }
                    }

                    Button {
                        text: models.isModelInstalled("qwen2.5:72b") ? "Installed" : "Download"
                        enabled: !models.isModelInstalled("qwen2.5:72b")
                        highlighted: !models.isModelInstalled("qwen2.5:72b")
                        onClicked: models.downloadModel("qwen2.5:72b")
                    }
                }
            }
        }

        // Coding Models
        Kirigami.Card {
            Layout.fillWidth: true
            visible: hardware.vramGB >= 30

            header: Kirigami.Heading {
                text: "Coding Specialists"
                level: 3
            }

            contentItem: ColumnLayout {
                Layout.margins: 16
                spacing: 15

                // DeepSeek Coder 33B
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 15

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 5

                        Label {
                            text: "DeepSeek Coder 33B"
                            font.pointSize: 14
                            font.bold: true
                        }

                        Label {
                            text: "Specialized for code generation, debugging, and refactoring"
                            wrapMode: Text.WordWrap
                            font.pointSize: 10
                            Layout.fillWidth: true
                        }

                        Label {
                            text: "Size: ~19GB | VRAM: 33GB required"
                            font.pointSize: 9
                            color: "#a6adc8"
                        }
                    }

                    Button {
                        text: models.isModelInstalled("deepseek-coder:33b") ? "Installed" : "Download"
                        enabled: !models.isModelInstalled("deepseek-coder:33b") && hardware.vramGB >= 33
                        highlighted: !models.isModelInstalled("deepseek-coder:33b") && hardware.vramGB >= 33
                        onClicked: models.downloadModel("deepseek-coder:33b")
                    }
                }
            }
        }

        // Lightweight Models (Always available)
        Kirigami.Card {
            Layout.fillWidth: true

            header: Kirigami.Heading {
                text: "Lightweight Models - Fast & Efficient"
                level: 3
            }

            contentItem: ColumnLayout {
                Layout.margins: 16
                spacing: 15

                // Llama 3.2 3B
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 15

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 5

                        Label {
                            text: "Llama 3.2 3B"
                            font.pointSize: 14
                            font.bold: true
                        }

                        Label {
                            text: "Small but capable - Great for testing and quick tasks"
                            wrapMode: Text.WordWrap
                            font.pointSize: 10
                            Layout.fillWidth: true
                        }

                        Label {
                            text: "Size: ~2GB | VRAM: 3GB required"
                            font.pointSize: 9
                            color: "#a6adc8"
                        }
                    }

                    Button {
                        text: models.isModelInstalled("llama3.2:3b") ? "Installed" : "Download"
                        enabled: !models.isModelInstalled("llama3.2:3b")
                        highlighted: !models.isModelInstalled("llama3.2:3b")
                        onClicked: models.downloadModel("llama3.2:3b")
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    height: 1
                    color: "#45475a"
                }

                // Llama 3.2 1B (Already installed)
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 15

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 5

                        Label {
                            text: "Llama 3.2 1B"
                            font.pointSize: 14
                            font.bold: true
                        }

                        Label {
                            text: "Ultra-lightweight - Pre-installed for initial testing"
                            wrapMode: Text.WordWrap
                            font.pointSize: 10
                            Layout.fillWidth: true
                        }

                        Label {
                            text: "Size: ~1.3GB | VRAM: 1GB required"
                            font.pointSize: 9
                            color: "#a6adc8"
                        }
                    }

                    Label {
                        text: "✓ Installed"
                        color: "#a6e3a1"
                        font.bold: true
                    }
                }
            }
        }

        // Info box
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 80
            color: "#313244"
            radius: 10

            RowLayout {
                anchors.fill: parent
                anchors.margins: 16
                spacing: 15

                Kirigami.Icon {
                    source: "info"
                    Layout.preferredWidth: 48
                    Layout.preferredHeight: 48
                    color: "#89b4fa"
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 5

                    Label {
                        text: "Download Times"
                        font.bold: true
                    }

                    Label {
                        text: "70B models: 10-30 minutes | 33B models: 5-15 minutes | 3B models: 1-3 minutes"
                        font.pointSize: 10
                        wrapMode: Text.WordWrap
                        Layout.fillWidth: true
                    }
                }
            }
        }

        // Actions
        RowLayout {
            Layout.alignment: Qt.AlignHCenter
            Layout.topMargin: 20
            spacing: 10

            Button {
                text: "Open Terminal (oterm)"
                icon.name: "utilities-terminal"
                onClicked: {
                    Qt.openUrlExternally("ghostty")
                }
            }

            Button {
                text: "Open Web UI"
                icon.name: "internet-web-browser"
                onClicked: {
                    Qt.openUrlExternally("http://localhost:8080")
                }
            }
        }
    }

    Component {
        id: hardwarePageComponent
        HardwarePage {}
    }
}
