#!/usr/bin/env python3
"""
qalarc_OS Welcome Window
A Qt/QML application that provides:
- Hardware verification
- AI model download wizard
- System tour
- Status dashboard
"""

import sys
import os
from pathlib import Path
from PyQt6.QtCore import QUrl, QObject, pyqtSlot, pyqtSignal, pyqtProperty
from PyQt6.QtGui import QGuiApplication, QIcon
from PyQt6.QtQml import QQmlApplicationEngine
from PyQt6.QtQuickControls2 import QQuickStyle

# Import backend
from backend import HardwareBackend, ModelBackend, SystemBackend


class WelcomeController(QObject):
    """Main controller connecting QML frontend to Python backends"""

    def __init__(self):
        super().__init__()
        self.hardware = HardwareBackend()
        self.models = ModelBackend()
        self.system = SystemBackend()

    @pyqtSlot()
    def markWelcomeComplete(self):
        """Mark that welcome window has been shown"""
        config_file = Path.home() / ".config" / "qalarc-welcome-shown"
        config_file.parent.mkdir(parents=True, exist_ok=True)
        config_file.touch()
        print("Welcome window marked as complete")

    @pyqtSlot(result=bool)
    def isFirstBoot(self):
        """Check if this is the first boot"""
        config_file = Path.home() / ".config" / "qalarc-welcome-shown"
        return not config_file.exists()


def main():
    """Main application entry point"""

    # Set up application
    app = QGuiApplication(sys.argv)
    app.setApplicationName("qalarc_OS Welcome")
    app.setApplicationVersion("1.0.0")
    app.setOrganizationName("qalarc_OS")

    # Use Breeze style (KDE's style)
    QQuickStyle.setStyle("org.kde.desktop")

    # Create QML engine
    engine = QQmlApplicationEngine()

    # Create controller and backends
    controller = WelcomeController()

    # Register backends with QML
    engine.rootContext().setContextProperty("controller", controller)
    engine.rootContext().setContextProperty("hardware", controller.hardware)
    engine.rootContext().setContextProperty("models", controller.models)
    engine.rootContext().setContextProperty("systemBackend", controller.system)

    # Load main QML file
    qml_file = Path(__file__).parent / "main.qml"
    engine.load(QUrl.fromLocalFile(str(qml_file)))

    if not engine.rootObjects():
        print("Failed to load QML file")
        return -1

    # Run application
    return app.exec()


if __name__ == "__main__":
    sys.exit(main())
