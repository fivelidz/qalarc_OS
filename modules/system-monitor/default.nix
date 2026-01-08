{ config, pkgs, lib, ... }:

{
  # System monitoring and information display
  # Includes Conky for UMA stats and system info overlay

  environment.systemPackages = with pkgs; [
    # System monitors
    btop       # Modern system monitor
    htop       # Classic system monitor
    nvtopPackages.amd  # GPU monitor for AMD
    radeontop  # AMD-specific GPU monitor
    conky      # Desktop system info overlay

    # Hardware info tools
    lshw
    pciutils
    usbutils
    lm_sensors
    smartmontools  # Disk health

    # Performance monitoring
    sysstat
    iotop
    iftop
    nethogs

    # Process management
    killall
    psmisc
  ];

  # Conky configuration for AMD Ryzen AI Max+ 395 UMA stats
  environment.etc."conky/qalarc-uma.conf".text = ''
    conky.config = {
        alignment = 'top_right',
        background = true,
        border_width = 1,
        cpu_avg_samples = 2,
        default_color = 'white',
        default_outline_color = 'white',
        default_shade_color = 'white',
        double_buffer = true,
        draw_borders = false,
        draw_graph_borders = true,
        draw_outline = false,
        draw_shades = false,
        extra_newline = false,
        font = 'JetBrains Mono:size=10',
        gap_x = 20,
        gap_y = 60,
        minimum_height = 5,
        minimum_width = 350,
        net_avg_samples = 2,
        no_buffers = true,
        out_to_console = false,
        out_to_ncurses = false,
        out_to_stderr = false,
        out_to_x = true,
        own_window = true,
        own_window_class = 'Conky',
        own_window_type = 'override',
        own_window_transparent = true,
        show_graph_range = false,
        show_graph_scale = false,
        stippled_borders = 0,
        update_interval = 2.0,
        uppercase = false,
        use_spacer = 'none',
        use_xft = true,
    }

    conky.text = [[
    ''${color white}''${font JetBrains Mono:bold:size=12}QALARC SYSTEM STATUS''${font}
    ''${color grey}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    ''${color white}Hostname: ''${color grey}$nodename
    ''${color white}Uptime: ''${color grey}$uptime

    ''${color white}''${font JetBrains Mono:bold:size=11}AMD Ryzen AI Max+ 395''${font}
    ''${color grey}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    ''${color white}CPU Usage: ''${color grey}$cpu% ''${cpubar 8,200}
    ''${color white}CPU Temp: ''${color grey}''${hwmon 0 temp 1}°C
    ''${color white}Freq: ''${color grey}''${freq_g}GHz
    ''${color white}Processes: ''${color grey}$processes (''${running_processes} running)

    ''${color white}''${font JetBrains Mono:bold:size=11}Memory (UMA)''${font}
    ''${color grey}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    ''${color white}System RAM: ''${color grey}$mem / $memmax ''${membar 8,150}
    ''${color white}RAM Usage: ''${color grey}$memperc%
    ''${color white}Swap: ''${color grey}$swap / $swapmax

    ''${color white}GPU (Radeon 8060S):
    ''${color grey}''${exec ${pkgs.radeontop}/bin/radeontop -d - -l 1 2>/dev/null | grep -oP 'gpu \K[0-9.]+' || echo "N/A"}% ''${color white}VRAM: ''${color grey}''${exec rocm-smi --showmeminfo vram --json 2>/dev/null | ${pkgs.jq}/bin/jq -r '.[0].vram_used' 2>/dev/null || echo "N/A"} MB

    ''${color white}''${font JetBrains Mono:bold:size=11}Storage''${font}
    ''${color grey}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    ''${color white}Root: ''${color grey}''${fs_used /} / ''${fs_size /} ''${fs_bar 8,150 /}
    ''${color white}/home: ''${color grey}''${fs_used /home} / ''${fs_size /home} ''${fs_bar 8,150 /home}
    ''${color white}LLMs: ''${color grey}''${fs_used /local-llms} / ''${fs_size /local-llms}

    ''${color white}''${font JetBrains Mono:bold:size=11}Network''${font}
    ''${color grey}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    ''${color white}Down: ''${color grey}''${downspeed} ''${color white}Up: ''${color grey}''${upspeed}
    ''${color white}Local IP: ''${color grey}''${addr}

    ''${color white}''${font JetBrains Mono:bold:size=11}AI Services''${font}
    ''${color grey}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    ''${color white}Ollama: ''${color grey}''${if_running ollama}RUNNING''${else}STOPPED''${endif}
    ''${color white}Models: ''${color grey}''${exec ls /local-llms/ollama/models 2>/dev/null | wc -l || echo "0"}
    ]]
  '';

  # Autostart Conky (optional - user can enable in KDE autostart settings)
  # systemd.user.services.conky = {
  #   description = "Conky system monitor";
  #   wantedBy = [ "graphical-session.target" ];
  #   serviceConfig = {
  #     ExecStart = "${pkgs.conky}/bin/conky -c /etc/conky/qalarc-uma.conf";
  #     Restart = "on-failure";
  #   };
  # };

  # System state export service (JSON for AI assistants)
  # NOTE: Disabled by default to avoid boot errors. Enable after full setup.
  # systemd.services.system-state-export = {
  #   description = "Export system state for AI assistant consumption";
  #   serviceConfig = {
  #     Type = "oneshot";
  #     ExecStart = pkgs.writeShellScript "export-system-state" ''
  #       #!/bin/sh
  #       # Export comprehensive system state as JSON
  #       mkdir -p /var/lib/qalarc
  #       cat > /var/lib/qalarc/system-state.json << EOF
  #       {
  #         "hostname": "$(hostname)",
  #         "uptime_seconds": $(cat /proc/uptime | cut -d' ' -f1),
  #         "last_updated": "$(date -Iseconds)"
  #       }
  #       EOF
  #     '';
  #   };
  # };
  #
  # systemd.timers.system-state-export = {
  #   wantedBy = [ "timers.target" ];
  #   timerConfig = {
  #     OnBootSec = "30s";
  #     OnUnitActiveSec = "1min";
  #   };
  # };

  # CLI AI assistant interface:
  # - System state: cat /var/lib/qalarc/system-state.json | jq
  # - Live monitor: btop (interactive) or htop
  # - GPU stats: cat /var/lib/qalarc/gpu-stats.json | jq
  # - Quick info: uname -a; free -h; df -h; lscpu
}
