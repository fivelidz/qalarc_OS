"""
Backend logic for qalarc_OS Welcome Window
Provides Python interfaces for QML frontend
"""

import subprocess
import json
import os
import requests
from pathlib import Path
from PyQt6.QtCore import QObject, pyqtSlot, pyqtSignal, pyqtProperty, QTimer


class HardwareBackend(QObject):
    """Hardware detection and verification"""

    hardwareDetected = pyqtSignal()

    def __init__(self):
        super().__init__()
        self._cpu_model = ""
        self._gpu_model = ""
        self._ram_total_gb = 0
        self._vram_gb = 0
        self._vram_status = "unknown"
        self._vram_recommendation = ""
        self._compatible = True

        # Auto-detect on startup
        QTimer.singleShot(100, self.detectHardware)

    @pyqtSlot()
    def detectHardware(self):
        """Run hardware detection"""
        try:
            # Try to use detect-hardware.sh if available
            detect_script = Path.home() / "projects" / "usb-installer" / "detect-hardware.sh"

            if detect_script.exists():
                result = subprocess.run(
                    [str(detect_script), "--json"],
                    capture_output=True,
                    text=True,
                    timeout=10
                )

                if result.returncode == 0:
                    data = json.loads(result.stdout)
                    self._cpu_model = data.get("cpu_model", "Unknown")
                    self._gpu_model = data.get("gpu_model", "Unknown")
                    self._ram_total_gb = int(data.get("ram_total_gb", 0))
                    self._vram_gb = int(data.get("vram_gb", 0))
                    self._vram_status = data.get("vram_status", "unknown")
                    self._vram_recommendation = data.get("vram_recommendation", "")
                    self._compatible = data.get("compatible", "false").lower() == "true"
                else:
                    self._fallback_detection()
            else:
                self._fallback_detection()

        except Exception as e:
            print(f"Hardware detection error: {e}")
            self._fallback_detection()

        self.hardwareDetected.emit()

    def _fallback_detection(self):
        """Fallback detection using basic system tools"""
        # CPU
        try:
            result = subprocess.run(
                ["lscpu"],
                capture_output=True,
                text=True
            )
            for line in result.stdout.split('\n'):
                if "Model name:" in line:
                    self._cpu_model = line.split(':', 1)[1].strip()
        except:
            self._cpu_model = "Detection failed"

        # RAM
        try:
            result = subprocess.run(
                ["free", "-g"],
                capture_output=True,
                text=True
            )
            for line in result.stdout.split('\n'):
                if line.startswith("Mem:"):
                    self._ram_total_gb = int(line.split()[1])
        except:
            self._ram_total_gb = 0

        # GPU
        try:
            result = subprocess.run(
                ["lspci"],
                capture_output=True,
                text=True
            )
            for line in result.stdout.split('\n'):
                if "VGA" in line and "AMD" in line:
                    self._gpu_model = line.split(':', 2)[2].strip()
                    break
        except:
            self._gpu_model = "Detection failed"

        # VRAM (try rocm-smi)
        try:
            result = subprocess.run(
                ["rocm-smi", "--showmeminfo", "vram"],
                capture_output=True,
                text=True
            )
            for line in result.stdout.split('\n'):
                if "VRAM Total Memory (B):" in line:
                    vram_bytes = int(line.split()[4])
                    self._vram_gb = int(vram_bytes / (1024 ** 3))
                    break

            # Determine status
            if self._vram_gb >= 90:
                self._vram_status = "excellent"
                self._vram_recommendation = "Ready for 70B+ models"
            elif self._vram_gb >= 60:
                self._vram_status = "good"
                self._vram_recommendation = "Consider BIOS update for 96GB"
            else:
                self._vram_status = "low"
                self._vram_recommendation = "BIOS configuration needed"

        except:
            self._vram_gb = 0
            self._vram_status = "unknown"
            self._vram_recommendation = "Could not detect VRAM"

    # QML Properties
    @pyqtProperty(str, notify=hardwareDetected)
    def cpuModel(self):
        return self._cpu_model

    @pyqtProperty(str, notify=hardwareDetected)
    def gpuModel(self):
        return self._gpu_model

    @pyqtProperty(int, notify=hardwareDetected)
    def ramTotalGB(self):
        return self._ram_total_gb

    @pyqtProperty(int, notify=hardwareDetected)
    def vramGB(self):
        return self._vram_gb

    @pyqtProperty(str, notify=hardwareDetected)
    def vramStatus(self):
        return self._vram_status

    @pyqtProperty(str, notify=hardwareDetected)
    def vramRecommendation(self):
        return self._vram_recommendation

    @pyqtProperty(bool, notify=hardwareDetected)
    def compatible(self):
        return self._compatible


class ModelBackend(QObject):
    """AI model management"""

    modelsLoaded = pyqtSignal()
    downloadProgress = pyqtSignal(str, int)  # model_name, progress_percent
    downloadComplete = pyqtSignal(str)  # model_name

    def __init__(self):
        super().__init__()
        self._available_models = []
        self._installed_models = []
        self._recommended_models = []

        # Load model database
        QTimer.singleShot(200, self.loadModels)

    @pyqtSlot()
    def loadModels(self):
        """Load available and installed models"""
        try:
            # Load model database
            db_path = Path.home() / "projects" / "model-manager" / "model-database.json"

            if db_path.exists():
                with open(db_path) as f:
                    data = json.load(f)
                    self._available_models = data.get("models", [])
            else:
                # Fallback: hardcoded popular models
                self._available_models = [
                    {
                        "name": "llama3.3:70b",
                        "size_gb": 40,
                        "vram_required": 70,
                        "category": "general",
                        "description": "Meta's Llama 3.3 70B - excellent for general tasks"
                    },
                    {
                        "name": "qwen2.5:72b",
                        "size_gb": 41,
                        "vram_required": 72,
                        "category": "general",
                        "description": "Qwen 2.5 72B - multilingual, strong reasoning"
                    },
                    {
                        "name": "deepseek-coder:33b",
                        "size_gb": 19,
                        "vram_required": 33,
                        "category": "coding",
                        "description": "DeepSeek Coder 33B - specialized for programming"
                    },
                    {
                        "name": "llama3.2:3b",
                        "size_gb": 2,
                        "vram_required": 3,
                        "category": "minimal",
                        "description": "Llama 3.2 3B - fast, efficient, good for testing"
                    }
                ]

            # Get installed models from Ollama
            self._checkInstalledModels()

            self.modelsLoaded.emit()

        except Exception as e:
            print(f"Error loading models: {e}")

    def _checkInstalledModels(self):
        """Check which models are already installed"""
        try:
            result = subprocess.run(
                ["ollama", "list"],
                capture_output=True,
                text=True
            )

            self._installed_models = []
            for line in result.stdout.split('\n')[1:]:  # Skip header
                if line.strip():
                    model_name = line.split()[0]
                    self._installed_models.append(model_name)

        except Exception as e:
            print(f"Error checking installed models: {e}")
            self._installed_models = []

    @pyqtSlot(str)
    def downloadModel(self, model_name):
        """Download a model using Ollama"""
        print(f"Downloading model: {model_name}")

        try:
            # Start download in background
            process = subprocess.Popen(
                ["ollama", "pull", model_name],
                stdout=subprocess.PIPE,
                stderr=subprocess.STDOUT,
                text=True
            )

            # Monitor progress (simplified - real implementation would parse output)
            for line in iter(process.stdout.readline, ''):
                if not line:
                    break
                print(line, end='')

            process.wait()

            if process.returncode == 0:
                self.downloadComplete.emit(model_name)
                self._checkInstalledModels()
            else:
                print(f"Download failed for {model_name}")

        except Exception as e:
            print(f"Error downloading model: {e}")

    @pyqtSlot(str, result=bool)
    def isModelInstalled(self, model_name):
        """Check if a model is installed"""
        return model_name in self._installed_models

    @pyqtSlot(int, result=list)
    def getModelsForVRAM(self, vram_gb):
        """Get models that fit in available VRAM"""
        compatible = []
        for model in self._available_models:
            if model.get("vram_required", 999) <= vram_gb:
                compatible.append(model)
        return compatible


class SystemBackend(QObject):
    """System status and information"""

    statusUpdated = pyqtSignal()

    def __init__(self):
        super().__init__()
        self._ollama_running = False
        self._disk_usage_percent = 0
        self._generation = "Unknown"

        # Check status periodically
        self.timer = QTimer()
        self.timer.timeout.connect(self.updateStatus)
        self.timer.start(5000)  # Every 5 seconds

        # Initial check
        QTimer.singleShot(300, self.updateStatus)

    @pyqtSlot()
    def updateStatus(self):
        """Update system status"""
        # Check if Ollama is running
        try:
            result = subprocess.run(
                ["systemctl", "is-active", "ollama"],
                capture_output=True,
                text=True
            )
            self._ollama_running = result.stdout.strip() == "active"
        except:
            self._ollama_running = False

        # Check disk usage
        try:
            result = subprocess.run(
                ["df", "-h", "/"],
                capture_output=True,
                text=True
            )
            lines = result.stdout.split('\n')
            if len(lines) > 1:
                usage = lines[1].split()[4].rstrip('%')
                self._disk_usage_percent = int(usage)
        except:
            self._disk_usage_percent = 0

        # Get NixOS generation
        try:
            result = subprocess.run(
                ["nixos-rebuild", "list-generations"],
                capture_output=True,
                text=True
            )
            # Parse current generation (simplified)
            for line in result.stdout.split('\n'):
                if "(current)" in line:
                    self._generation = line.split()[0]
                    break
        except:
            self._generation = "Unknown"

        self.statusUpdated.emit()

    @pyqtProperty(bool, notify=statusUpdated)
    def ollamaRunning(self):
        return self._ollama_running

    @pyqtProperty(int, notify=statusUpdated)
    def diskUsagePercent(self):
        return self._disk_usage_percent

    @pyqtProperty(str, notify=statusUpdated)
    def generation(self):
        return self._generation

    @pyqtSlot()
    def startOllama(self):
        """Start Ollama service"""
        try:
            subprocess.run(["sudo", "systemctl", "start", "ollama"])
            QTimer.singleShot(1000, self.updateStatus)
        except Exception as e:
            print(f"Error starting Ollama: {e}")

    @pyqtSlot(result=str)
    def getUsername(self):
        """Get current username"""
        return os.getenv("USER", "qalarc")

    @pyqtSlot(result=str)
    def getHostname(self):
        """Get system hostname"""
        try:
            return subprocess.run(
                ["hostname"],
                capture_output=True,
                text=True
            ).stdout.strip()
        except:
            return "qalarc-workstation"
