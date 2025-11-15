{ config, pkgs, lib, ... }:

{
  # Media tools: browsers, video/audio, graphics, file conversion

  environment.systemPackages = with pkgs; [
    # Web browsers
    brave      # Privacy-focused Chromium-based browser
    google-chrome  # Google Chrome
    firefox    # Backup browser

    # Video players
    vlc
    mpv        # Lightweight, powerful media player

    # Audio tools
    pavucontrol    # PulseAudio/PipeWire volume control GUI
    easyeffects    # Audio effects for PipeWire

    # Graphics and image editing
    gimp           # Image editor (like Photoshop)
    inkscape       # Vector graphics editor (like Illustrator)
    krita          # Digital painting

    # Image viewers
    gwenview       # KDE image viewer
    feh            # Lightweight image viewer

    # Video editing
    kdenlive       # KDE video editor
    # davinci-resolve  # Professional video editor (if available)

    # Screen recording
    obs-studio     # Streaming/recording software
    simplescreenrecorder

    # Screenshot tools (already have Spectacle from KDE)
    flameshot      # Advanced screenshot tool

    # File conversion - FFmpeg (the most important tool!)
    ffmpeg-full    # Full FFmpeg with all codecs

    # Audio/Video encoding helpers
    handbrake      # Video transcoding GUI

    # Document viewers
    okular         # KDE document viewer (PDF, ePub, etc.)
    evince         # GNOME document viewer (backup)

    # Office suite
    libreoffice-qt # LibreOffice with Qt6/KDE integration

    # Torrent client (optional)
    # qbittorrent

    # E-book management
    # calibre

    # Communication (optional)
    # discord
    # telegram-desktop
    # slack
  ];

  # FFmpeg helper script for common conversions
  environment.systemPackages = with pkgs; [
    (writeShellScriptBin "qalarc-convert" ''
      #!/bin/sh
      # Media conversion helper for AI assistants and users

      show_help() {
        cat << EOF
      qalarc-convert - Media file conversion helper

      Usage:
        qalarc-convert video <input> <output>  # Convert video to MP4 (H.264)
        qalarc-convert audio <input> <output>  # Convert audio to MP3
        qalarc-convert gif <input> <output>    # Convert video to GIF
        qalarc-convert compress <input> <output> <crf>  # Compress video (crf: 0-51, lower=better)

      Examples:
        qalarc-convert video input.mov output.mp4
        qalarc-convert audio song.flac song.mp3
        qalarc-convert gif video.mp4 animation.gif
        qalarc-convert compress large.mp4 small.mp4 28
      EOF
      }

      if [ $# -lt 2 ]; then
        show_help
        exit 1
      fi

      ACTION=$1
      INPUT=$2
      OUTPUT=$3

      case $ACTION in
        video)
          ${pkgs.ffmpeg-full}/bin/ffmpeg -i "$INPUT" -c:v libx264 -crf 23 -preset medium -c:a aac -b:a 128k "$OUTPUT"
          ;;
        audio)
          ${pkgs.ffmpeg-full}/bin/ffmpeg -i "$INPUT" -c:a libmp3lame -b:a 320k "$OUTPUT"
          ;;
        gif)
          ${pkgs.ffmpeg-full}/bin/ffmpeg -i "$INPUT" -vf "fps=10,scale=720:-1:flags=lanczos" -c:v gif "$OUTPUT"
          ;;
        compress)
          CRF=''${4:-28}
          ${pkgs.ffmpeg-full}/bin/ffmpeg -i "$INPUT" -c:v libx265 -crf $CRF -preset medium -c:a aac -b:a 128k "$OUTPUT"
          ;;
        *)
          echo "Unknown action: $ACTION"
          show_help
          exit 1
          ;;
      esac

      echo "Conversion complete: $OUTPUT"
    '')
  ];

  # Browser configuration notes for AI assistants:
  # - Brave: ~/.config/BraveSoftware/Brave-Browser/
  # - Chrome: ~/.config/google-chrome/
  # - Firefox: ~/.mozilla/firefox/

  # Media format support (codecs)
  hardware.graphics.extraPackages = with pkgs; [
    # AMD hardware video acceleration
    libva
    libvdpau-va-gl
    vaapiVdpau
  ];

  # CLI AI assistant interface:
  # - Convert files: qalarc-convert <action> <input> <output>
  # - Check codecs: ffmpeg -codecs
  # - Media info: ffprobe <file> -show_format -show_streams -print_format json
}
