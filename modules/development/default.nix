{ config, pkgs, lib, ... }:

{
  # Development tools and environments

  environment.systemPackages = with pkgs; [
    # Code editors
    vscode-fhs  # VSCode with FHS environment for extensions
    neovim
    vim

    # Terminal multiplexer
    tmux

    # Modern terminal emulator
    ghostty

    # Git and version control
    git
    git-lfs
    gh  # GitHub CLI
    lazygit  # Terminal UI for git

    # Build tools and compilers
    gcc
    clang
    cmake
    gnumake
    ninja

    # Programming languages and runtimes
    # Python (already in ai-ml module, but include build tools)
    python312Full
    python312Packages.pipx
    python312Packages.virtualenv

    # Node.js and JavaScript
    nodejs_22
    nodePackages.npm
    nodePackages.pnpm
    yarn

    # Rust
    rustc
    cargo
    rustfmt
    clippy

    # Go
    go

    # Java/JVM (optional)
    # jdk21

    # Nix development tools
    nil  # Nix LSP
    nixpkgs-fmt
    nixd
    alejandra  # Nix formatter

    # Container tools
    docker-compose
    podman-compose
    buildah
    skopeo

    # Development utilities
    direnv  # Environment management
    jq  # JSON processor (important for AI assistants!)
    yq  # YAML processor
    ripgrep  # Fast grep
    fd  # Fast find
    bat  # Better cat
    eza  # Better ls
    fzf  # Fuzzy finder
    zoxide  # Smart cd

    # Network development
    postman
    insomnia  # REST client

    # Database clients
    dbeaver-bin  # Universal database client

    # Debugging and profiling
    gdb
    valgrind
    strace
    ltrace
    perf-tools

    # Documentation
    man-pages
    man-pages-posix
    tldr
  ];

  # Git configuration
  programs.git = {
    enable = true;
    lfs.enable = true;
  };

  # Direnv for project-specific environments
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  # Neovim with plugins (basic config)
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    configure = {
      customRC = ''
        set number
        set relativenumber
        set tabstop=2
        set shiftwidth=2
        set expandtab
        syntax on
      '';
    };
  };

  # TMUX configuration
  programs.tmux = {
    enable = true;
    keyMode = "vi";
    terminal = "screen-256color";
    extraConfig = ''
      set -g mouse on
      set -g history-limit 10000
    '';
  };

  # VSCode configuration path (for AI assistants to modify)
  # Config location: ~/.config/Code/User/settings.json
  # Extensions location: ~/.vscode/extensions/

  # Docker/Podman already enabled in ai-ml module
  virtualisation.docker.enable = true;

  # CLI AI assistant notes:
  # - Project config: Often in .envrc (direnv), flake.nix, or package.json
  # - VSCode settings: ~/.config/Code/User/settings.json
  # - Git config: ~/.gitconfig
  # - Available languages: python, node, rust, go (check: which python3, node, cargo, go)
}
