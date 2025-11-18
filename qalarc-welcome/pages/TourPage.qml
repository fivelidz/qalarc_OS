import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami

Kirigami.ScrollablePage {
    title: "Quick Tour"

    ColumnLayout {
        width: parent.width
        spacing: 25

        // Header
        Label {
            text: "qalarc_OS Quick Tour"
            font.pointSize: 20
            font.bold: true
        }

        Label {
            text: "Learn about the key features and tools in your qalarc_OS installation."
            wrapMode: Text.WordWrap
            Layout.fillWidth: true
        }

        // Ghostty Terminal
        Kirigami.Card {
            Layout.fillWidth: true

            header: RowLayout {
                Kirigami.Icon {
                    source: "utilities-terminal"
                    Layout.preferredWidth: 48
                    Layout.preferredHeight: 48
                    color: "#89b4fa"
                }

                Kirigami.Heading {
                    text: "Ghostty Terminal"
                    level: 2
                }
            }

            contentItem: ColumnLayout {
                Layout.margins: 16
                spacing: 10

                Label {
                    text: "Your default terminal with GPU acceleration and beautiful themes."
                    wrapMode: Text.WordWrap
                    Layout.fillWidth: true
                }

                Label {
                    text: "• Launches automatically with AI welcome screen\n• Catppuccin Mocha color scheme\n• Opens to ~/Models directory\n• Configured in ~/.config/ghostty/config"
                    wrapMode: Text.WordWrap
                    Layout.fillWidth: true
                }

                Button {
                    text: "Open Ghostty"
                    icon.name: "utilities-terminal"
                    onClicked: Qt.openUrlExternally("ghostty")
                }
            }
        }

        // AI Tools
        Kirigami.Card {
            Layout.fillWidth: true

            header: RowLayout {
                Kirigami.Icon {
                    source: "ai-assistant"
                    Layout.preferredWidth: 48
                    Layout.preferredHeight: 48
                    color: "#a6e3a1"
                }

                Kirigami.Heading {
                    text: "AI Tools"
                    level: 2
                }
            }

            contentItem: ColumnLayout {
                Layout.margins: 16
                spacing: 15

                Label {
                    text: "Complete AI development stack with local LLM inference."
                    wrapMode: Text.WordWrap
                    Layout.fillWidth: true
                    font.bold: true
                }

                GridLayout {
                    columns: 2
                    columnSpacing: 20
                    rowSpacing: 10
                    Layout.fillWidth: true

                    Label {
                        text: "oterm"
                        font.bold: true
                        color: "#89b4fa"
                    }
                    Label {
                        text: "Beautiful TUI for Ollama - run 'oterm' in terminal"
                        wrapMode: Text.WordWrap
                        Layout.fillWidth: true
                    }

                    Label {
                        text: "Ollama"
                        font.bold: true
                        color: "#89b4fa"
                    }
                    Label {
                        text: "Local LLM server with ROCm acceleration"
                        wrapMode: Text.WordWrap
                        Layout.fillWidth: true
                    }

                    Label {
                        text: "Open WebUI"
                        font.bold: true
                        color: "#89b4fa"
                    }
                    Label {
                        text: "Web interface at http://localhost:8080"
                        wrapMode: Text.WordWrap
                        Layout.fillWidth: true
                    }

                    Label {
                        text: "llama.cpp"
                        font.bold: true
                        color: "#89b4fa"
                    }
                    Label {
                        text: "GGUF model inference engine"
                        wrapMode: Text.WordWrap
                        Layout.fillWidth: true
                    }
                }
            }
        }

        // Snapshots
        Kirigami.Card {
            Layout.fillWidth: true

            header: RowLayout {
                Kirigami.Icon {
                    source: "time-scheduler"
                    Layout.preferredWidth: 48
                    Layout.preferredHeight: 48
                    color: "#f9e2af"
                }

                Kirigami.Heading {
                    text: "BTRFS Snapshots"
                    level: 2
                }
            }

            contentItem: ColumnLayout {
                Layout.margins: 16
                spacing: 10

                Label {
                    text: "Automatic system snapshots for easy rollback and recovery."
                    wrapMode: Text.WordWrap
                    Layout.fillWidth: true
                }

                Label {
                    text: "• Snapshot created on every boot\n• Hourly snapshots (keep 10)\n• Daily snapshots (keep 7)\n• Weekly snapshots (keep 4)\n• Manual snapshots: 'sudo snapper create -d \"description\"'"
                    wrapMode: Text.WordWrap
                    Layout.fillWidth: true
                }

                Button {
                    text: "View Snapshots"
                    icon.name: "view-list-details"
                    onClicked: Qt.openUrlExternally("konsole -e snapper list")
                }
            }
        }

        // Development Tools
        Kirigami.Card {
            Layout.fillWidth: true

            header: RowLayout {
                Kirigami.Icon {
                    source: "code"
                    Layout.preferredWidth: 48
                    Layout.preferredHeight: 48
                    color: "#cba6f7"
                }

                Kirigami.Heading {
                    text: "Development Environment"
                    level: 2
                }
            }

            contentItem: ColumnLayout {
                Layout.margins: 16
                spacing: 10

                Label {
                    text: "Complete development stack pre-installed."
                    wrapMode: Text.WordWrap
                    Layout.fillWidth: true
                }

                GridLayout {
                    columns: 2
                    columnSpacing: 20
                    rowSpacing: 8
                    Layout.fillWidth: true

                    Label { text: "Editors:"; font.bold: true }
                    Label { text: "VSCode, Neovim, Vim" }

                    Label { text: "Languages:"; font.bold: true }
                    Label { text: "Python, Node.js, Rust, Go" }

                    Label { text: "Containers:"; font.bold: true }
                    Label { text: "Docker, Podman" }

                    Label { text: "Version Control:"; font.bold: true }
                    Label { text: "Git, GitHub CLI (gh)" }
                }
            }
        }

        // Projects Folder
        Kirigami.Card {
            Layout.fillWidth: true

            header: RowLayout {
                Kirigami.Icon {
                    source: "folder"
                    Layout.preferredWidth: 48
                    Layout.preferredHeight: 48
                    color: "#fab387"
                }

                Kirigami.Heading {
                    text: "Project Structure"
                    level: 2
                }
            }

            contentItem: ColumnLayout {
                Layout.margins: 16
                spacing: 10

                Label {
                    text: "Organized folder structure for your work."
                    wrapMode: Text.WordWrap
                    Layout.fillWidth: true
                }

                Label {
                    text: "~/Models/ - AI model storage (HuggingFace, Ollama, GGUF)\n~/projects/ - Your development projects\n~/Documents/qalarc-os-setup/ - Installation documentation\n~/claude/OM/ - System documentation and ideas"
                    wrapMode: Text.WordWrap
                    Layout.fillWidth: true
                    font.family: "monospace"
                }

                Button {
                    text: "Open Projects Folder"
                    icon.name: "folder-open"
                    onClicked: Qt.openUrlExternally("file://" + systemBackend.getUsername() + "/projects")
                }
            }
        }

        // Documentation
        Kirigami.Card {
            Layout.fillWidth: true

            header: RowLayout {
                Kirigami.Icon {
                    source: "help-contents"
                    Layout.preferredWidth: 48
                    Layout.preferredHeight: 48
                    color: "#94e2d5"
                }

                Kirigami.Heading {
                    text: "Documentation"
                    level: 2
                }
            }

            contentItem: ColumnLayout {
                Layout.margins: 16
                spacing: 10

                Label {
                    text: "Comprehensive guides and references."
                    wrapMode: Text.WordWrap
                    Layout.fillWidth: true
                }

                ColumnLayout {
                    spacing: 5

                    Button {
                        text: "BIOS Setup Guide (for 96GB VRAM)"
                        icon.name: "document"
                        Layout.fillWidth: true
                        onClicked: Qt.openUrlExternally("file://" + systemBackend.getUsername() + "/Documents/qalarc-os-setup/BIOS-SETUP-GUIDE.md")
                    }

                    Button {
                        text: "Phase 7 Summary"
                        icon.name: "document"
                        Layout.fillWidth: true
                        onClicked: Qt.openUrlExternally("file://" + systemBackend.getUsername() + "/Documents/qalarc-os-setup/PHASE7-COMPLETE-SUMMARY.md")
                    }

                    Button {
                        text: "Project Roadmap"
                        icon.name: "document"
                        Layout.fillWidth: true
                        onClicked: Qt.openUrlExternally("file://" + systemBackend.getUsername() + "/claude/OM/ideas/00-PROJECT-ROADMAP.md")
                    }
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
