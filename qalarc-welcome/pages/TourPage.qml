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

        // Complete Application Inventory
        Kirigami.Card {
            Layout.fillWidth: true

            header: RowLayout {
                Kirigami.Icon {
                    source: "application-menu"
                    Layout.preferredWidth: 48
                    Layout.preferredHeight: 48
                    color: "#cba6f7"
                }

                Kirigami.Heading {
                    text: "Complete Application Inventory (130+ Apps)"
                    level: 2
                }
            }

            contentItem: ColumnLayout {
                Layout.margins: 16
                spacing: 15

                Label {
                    text: "Your AI Workstation profile includes 130+ carefully selected applications. Click categories to expand."
                    wrapMode: Text.WordWrap
                    Layout.fillWidth: true
                    font.bold: true
                }

                // Terminal & Shell
                Kirigami.FormCard {
                    Layout.fillWidth: true

                    Kirigami.AbstractFormDelegate {
                        Layout.fillWidth: true
                        contentItem: ColumnLayout {
                            Label {
                                text: "🖥️ Terminal & Shell"
                                font.bold: true
                                font.pointSize: 12
                                color: "#89b4fa"
                            }
                            Label {
                                text: "Ghostty (GPU-accelerated), Konsole (KDE terminal), tmux (session manager)"
                                wrapMode: Text.WordWrap
                                Layout.fillWidth: true
                            }
                        }
                    }
                }

                // Code Editors
                Kirigami.FormCard {
                    Layout.fillWidth: true

                    Kirigami.AbstractFormDelegate {
                        Layout.fillWidth: true
                        contentItem: ColumnLayout {
                            Label {
                                text: "✏️ Code Editors"
                                font.bold: true
                                font.pointSize: 12
                                color: "#89b4fa"
                            }
                            Label {
                                text: "VSCode (FHS version), Neovim, Vim, Kate (KDE Advanced Text Editor)"
                                wrapMode: Text.WordWrap
                                Layout.fillWidth: true
                            }
                        }
                    }
                }

                // Version Control
                Kirigami.FormCard {
                    Layout.fillWidth: true

                    Kirigami.AbstractFormDelegate {
                        Layout.fillWidth: true
                        contentItem: ColumnLayout {
                            Label {
                                text: "🔀 Version Control"
                                font.bold: true
                                font.pointSize: 12
                                color: "#a6e3a1"
                            }
                            Label {
                                text: "Git, Git LFS, GitHub CLI (gh), Lazygit (terminal UI)"
                                wrapMode: Text.WordWrap
                                Layout.fillWidth: true
                            }
                        }
                    }
                }

                // Build Tools & Compilers
                Kirigami.FormCard {
                    Layout.fillWidth: true

                    Kirigami.AbstractFormDelegate {
                        Layout.fillWidth: true
                        contentItem: ColumnLayout {
                            Label {
                                text: "🔨 Build Tools & Compilers"
                                font.bold: true
                                font.pointSize: 12
                                color: "#f9e2af"
                            }
                            Label {
                                text: "GCC, Clang, CMake, GNU Make, Ninja"
                                wrapMode: Text.WordWrap
                                Layout.fillWidth: true
                            }
                        }
                    }
                }

                // Programming Languages
                Kirigami.FormCard {
                    Layout.fillWidth: true

                    Kirigami.AbstractFormDelegate {
                        Layout.fillWidth: true
                        contentItem: ColumnLayout {
                            Label {
                                text: "💻 Programming Languages"
                                font.bold: true
                                font.pointSize: 12
                                color: "#cba6f7"
                            }
                            Label {
                                text: "Python 3.12 (with pipx, virtualenv) • Node.js 22 (npm, pnpm, yarn) • Rust (cargo, rustfmt, clippy) • Go"
                                wrapMode: Text.WordWrap
                                Layout.fillWidth: true
                            }
                        }
                    }
                }

                // Nix Development
                Kirigami.FormCard {
                    Layout.fillWidth: true

                    Kirigami.AbstractFormDelegate {
                        Layout.fillWidth: true
                        contentItem: ColumnLayout {
                            Label {
                                text: "❄️ Nix Development"
                                font.bold: true
                                font.pointSize: 12
                                color: "#89dceb"
                            }
                            Label {
                                text: "nil (Nix LSP), nixpkgs-fmt, nixd (alternative LSP), alejandra (formatter)"
                                wrapMode: Text.WordWrap
                                Layout.fillWidth: true
                            }
                        }
                    }
                }

                // Container Tools
                Kirigami.FormCard {
                    Layout.fillWidth: true

                    Kirigami.AbstractFormDelegate {
                        Layout.fillWidth: true
                        contentItem: ColumnLayout {
                            Label {
                                text: "📦 Container Tools"
                                font.bold: true
                                font.pointSize: 12
                                color: "#89b4fa"
                            }
                            Label {
                                text: "Docker + docker-compose, Podman + podman-compose, Buildah, Skopeo, ctop, dive, lazydocker"
                                wrapMode: Text.WordWrap
                                Layout.fillWidth: true
                            }
                        }
                    }
                }

                // AI/ML Stack
                Kirigami.FormCard {
                    Layout.fillWidth: true

                    Kirigami.AbstractFormDelegate {
                        Layout.fillWidth: true
                        contentItem: ColumnLayout {
                            Label {
                                text: "🤖 AI/ML Stack"
                                font.bold: true
                                font.pointSize: 12
                                color: "#a6e3a1"
                            }
                            Label {
                                text: "LLM Servers: Ollama (with ROCm), oterm (Textual TUI), llama-cpp\n" +
                                      "ML Libraries: PyTorch, Transformers, Textual, Rich\n" +
                                      "GPU Compute: ROCm runtime, rocm-smi, rocminfo, clr (OpenCL/HIP), clinfo, Vulkan layers"
                                wrapMode: Text.WordWrap
                                Layout.fillWidth: true
                            }
                        }
                    }
                }

                // Development Utilities
                Kirigami.FormCard {
                    Layout.fillWidth: true

                    Kirigami.AbstractFormDelegate {
                        Layout.fillWidth: true
                        contentItem: ColumnLayout {
                            Label {
                                text: "🛠️ Development Utilities"
                                font.bold: true
                                font.pointSize: 12
                                color: "#fab387"
                            }
                            Label {
                                text: "direnv, jq (JSON), yq-go (YAML), ripgrep (rg), fd, bat (better cat), eza (better ls), fzf (fuzzy finder), zoxide (smart cd)"
                                wrapMode: Text.WordWrap
                                Layout.fillWidth: true
                            }
                        }
                    }
                }

                // API & Database Tools
                Kirigami.FormCard {
                    Layout.fillWidth: true

                    Kirigami.AbstractFormDelegate {
                        Layout.fillWidth: true
                        contentItem: ColumnLayout {
                            Label {
                                text: "🔌 API & Database Tools"
                                font.bold: true
                                font.pointSize: 12
                                color: "#f38ba8"
                            }
                            Label {
                                text: "API: Postman, Insomnia • Database: DBeaver (universal client)"
                                wrapMode: Text.WordWrap
                                Layout.fillWidth: true
                            }
                        }
                    }
                }

                // Debugging & Profiling
                Kirigami.FormCard {
                    Layout.fillWidth: true

                    Kirigami.AbstractFormDelegate {
                        Layout.fillWidth: true
                        contentItem: ColumnLayout {
                            Label {
                                text: "🐛 Debugging & Profiling"
                                font.bold: true
                                font.pointSize: 12
                                color: "#eba0ac"
                            }
                            Label {
                                text: "GDB (GNU Debugger), Valgrind (memory debugging), strace (system calls), ltrace (library calls), perf (performance analysis)"
                                wrapMode: Text.WordWrap
                                Layout.fillWidth: true
                            }
                        }
                    }
                }

                // System Monitors
                Kirigami.FormCard {
                    Layout.fillWidth: true

                    Kirigami.AbstractFormDelegate {
                        Layout.fillWidth: true
                        contentItem: ColumnLayout {
                            Label {
                                text: "📊 System Monitors"
                                font.bold: true
                                font.pointSize: 12
                                color: "#94e2d5"
                            }
                            Label {
                                text: "btop (modern), htop (interactive), nvtop (GPU), radeontop (AMD GPU), Conky (desktop overlay)"
                                wrapMode: Text.WordWrap
                                Layout.fillWidth: true
                            }
                        }
                    }
                }

                // Hardware Info
                Kirigami.FormCard {
                    Layout.fillWidth: true

                    Kirigami.AbstractFormDelegate {
                        Layout.fillWidth: true
                        contentItem: ColumnLayout {
                            Label {
                                text: "🔍 Hardware Info & Monitoring"
                                font.bold: true
                                font.pointSize: 12
                                color: "#f5c2e7"
                            }
                            Label {
                                text: "lshw, pciutils, usbutils, lm_sensors, smartmontools (S.M.A.R.T.), sysstat, iotop, iftop, nethogs"
                                wrapMode: Text.WordWrap
                                Layout.fillWidth: true
                            }
                        }
                    }
                }

                // Browsers
                Kirigami.FormCard {
                    Layout.fillWidth: true

                    Kirigami.AbstractFormDelegate {
                        Layout.fillWidth: true
                        contentItem: ColumnLayout {
                            Label {
                                text: "🌐 Web Browsers"
                                font.bold: true
                                font.pointSize: 12
                                color: "#89b4fa"
                            }
                            Label {
                                text: "Brave (PRIMARY - privacy-focused), Google Chrome (compatibility testing)"
                                wrapMode: Text.WordWrap
                                Layout.fillWidth: true
                            }
                        }
                    }
                }

                // Media Players
                Kirigami.FormCard {
                    Layout.fillWidth: true

                    Kirigami.AbstractFormDelegate {
                        Layout.fillWidth: true
                        contentItem: ColumnLayout {
                            Label {
                                text: "🎬 Media & Audio"
                                font.bold: true
                                font.pointSize: 12
                                color: "#f9e2af"
                            }
                            Label {
                                text: "Video: VLC, MPV • Audio: pavucontrol (PulseAudio/PipeWire), EasyEffects"
                                wrapMode: Text.WordWrap
                                Layout.fillWidth: true
                            }
                        }
                    }
                }

                // Graphics & Image Editing
                Kirigami.FormCard {
                    Layout.fillWidth: true

                    Kirigami.AbstractFormDelegate {
                        Layout.fillWidth: true
                        contentItem: ColumnLayout {
                            Label {
                                text: "🎨 Graphics & Image Editing"
                                font.bold: true
                                font.pointSize: 12
                                color: "#cba6f7"
                            }
                            Label {
                                text: "GIMP (raster editing), Inkscape (vector graphics), Krita (digital painting), Gwenview (viewer), feh (lightweight viewer)"
                                wrapMode: Text.WordWrap
                                Layout.fillWidth: true
                            }
                        }
                    }
                }

                // Video Editing & Recording
                Kirigami.FormCard {
                    Layout.fillWidth: true

                    Kirigami.AbstractFormDelegate {
                        Layout.fillWidth: true
                        contentItem: ColumnLayout {
                            Label {
                                text: "🎥 Video Editing & Recording"
                                font.bold: true
                                font.pointSize: 12
                                color: "#f38ba8"
                            }
                            Label {
                                text: "Kdenlive (video editor), OBS Studio (streaming/recording), SimpleScreenRecorder, Flameshot (screenshots), FFmpeg, Handbrake"
                                wrapMode: Text.WordWrap
                                Layout.fillWidth: true
                            }
                        }
                    }
                }

                // Documents & Office
                Kirigami.FormCard {
                    Layout.fillWidth: true

                    Kirigami.AbstractFormDelegate {
                        Layout.fillWidth: true
                        contentItem: ColumnLayout {
                            Label {
                                text: "📄 Documents & Office"
                                font.bold: true
                                font.pointSize: 12
                                color: "#89dceb"
                            }
                            Label {
                                text: "LibreOffice (complete suite - Qt6), Okular (PDF viewer), Evince (document viewer)"
                                wrapMode: Text.WordWrap
                                Layout.fillWidth: true
                            }
                        }
                    }
                }

                // KDE Applications
                Kirigami.FormCard {
                    Layout.fillWidth: true

                    Kirigami.AbstractFormDelegate {
                        Layout.fillWidth: true
                        contentItem: ColumnLayout {
                            Label {
                                text: "🔷 KDE Applications"
                                font.bold: true
                                font.pointSize: 12
                                color: "#89b4fa"
                            }
                            Label {
                                text: "Kate (text editor), Konsole (terminal), Dolphin (file manager), Ark (archives), Spectacle (screenshots), " +
                                      "Filelight (disk usage), KWalletManager (passwords), KDE Connect (phone integration), Krohnkite (tiling WM)"
                                wrapMode: Text.WordWrap
                                Layout.fillWidth: true
                            }
                        }
                    }
                }

                // Networking Tools
                Kirigami.FormCard {
                    Layout.fillWidth: true

                    Kirigami.AbstractFormDelegate {
                        Layout.fillWidth: true
                        contentItem: ColumnLayout {
                            Label {
                                text: "🌍 Networking Tools"
                                font.bold: true
                                font.pointSize: 12
                                color: "#a6e3a1"
                            }
                            Label {
                                text: "curl, wget, nmap (scanner), iperf3 (benchmarking), mtr (diagnostics), traceroute, tcpdump, Wireshark (protocol analyzer)"
                                wrapMode: Text.WordWrap
                                Layout.fillWidth: true
                            }
                        }
                    }
                }

                // Documentation
                Kirigami.FormCard {
                    Layout.fillWidth: true

                    Kirigami.AbstractFormDelegate {
                        Layout.fillWidth: true
                        contentItem: ColumnLayout {
                            Label {
                                text: "📚 Documentation"
                                font.bold: true
                                font.pointSize: 12
                                color: "#fab387"
                            }
                            Label {
                                text: "man-pages (Linux manuals), man-pages-posix (POSIX manuals), tldr (simplified man pages)"
                                wrapMode: Text.WordWrap
                                Layout.fillWidth: true
                            }
                        }
                    }
                }

                // Total count label
                Label {
                    text: "Total: 130+ applications across 20+ categories"
                    font.italic: true
                    color: "#a6e3a1"
                    Layout.alignment: Qt.AlignHCenter
                    Layout.topMargin: 10
                }

                Button {
                    text: "View Full Inventory"
                    icon.name: "document"
                    Layout.alignment: Qt.AlignHCenter
                    onClicked: Qt.openUrlExternally("file:///home/" + systemBackend.getUsername() + "/projects/APP-INVENTORY.md")
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
