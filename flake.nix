{
  description = "qalarc_OS - NixOS deployment system for AMD Ryzen AI Max+ 395 systems";

  inputs = {
    # NixOS stable channel
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";

    # Chaotic-Nyx for CachyOS kernel and bleeding-edge packages
    chaotic.url = "github:chaotic-cx/nyx/nyxpkgs-unstable";

    # nixified.ai for AI/ML packages
    nixified-ai.url = "github:nixified-ai/flake";

    # Home Manager for user-level configuration
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, chaotic, nixified-ai, home-manager, ... }@inputs:
    let
      system = "x86_64-linux";

      # Helper function to create a host configuration
      mkHost = { hostname, snapperModule ? ./modules/snapper }: nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = {
          inherit inputs;
          inherit nixified-ai;
        };
        modules = [
          # Import Chaotic-Nyx modules
          chaotic.nixosModules.default

          # Host-specific configuration
          ./hosts/${hostname}/configuration.nix
          ./hosts/${hostname}/hardware-configuration.nix

          # Common modules
          ./modules/desktop
          ./modules/ai-ml
          ./modules/nixos-ai-assistant
          snapperModule  # Can be default or single-drive variant
          ./modules/networking
          ./modules/development
          ./modules/media
          ./modules/system-monitor
          ./modules/torrent
          ./modules/vpn-infrastructure

          # Performance overlay
          {
            nixpkgs.overlays = [
              (import ./overlays/performance.nix)
            ];
          }

          # Home Manager integration
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
          }
        ];
      };
    in
    {
      # Define NixOS configurations for each host
      nixosConfigurations = {
        # Dual-drive configuration (2TB system + 4TB AI/context drives)
        gmktec-01 = mkHost {
          hostname = "gmktec-01";
          # Uses default snapper (includes /context subvolume)
        };

        # Single-drive configuration (everything on 1.8TB drive)
        gmktec-01-single-drive = mkHost {
          hostname = "gmktec-01-single-drive";
          snapperModule = ./modules/snapper/single-drive.nix;
        };

        # Minimal configuration - just KDE + SSH (no modules)
        gmktec-01-minimal = nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            ./hosts/gmktec-01-minimal/configuration.nix
            ./hosts/gmktec-01-minimal/hardware-configuration.nix
          ];
        };

        # Alias for current hostname
        gmktec-minimal = nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            ./hosts/gmktec-01-minimal/configuration.nix
            ./hosts/gmktec-01-minimal/hardware-configuration.nix
          ];
        };

        # Portable external drive - self-contained bootable OS with LUKS
        portable-external = nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            ./hosts/portable-external/configuration.nix
            ./hosts/portable-external/hardware-configuration.nix
          ];
        };

        # Custom installer ISO with qalarc_OS pre-loaded
        installer = nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            ./installer/iso-config.nix
          ];
        };
      };

      # Development shell for working on this configuration
      devShells.${system}.default = nixpkgs.legacyPackages.${system}.mkShell {
        buildInputs = with nixpkgs.legacyPackages.${system}; [
          git
          nixpkgs-fmt
          nil # Nix LSP
        ];
        shellHook = ''
          echo "qalarc_OS development environment"
          echo "Available commands:"
          echo "  nixos-rebuild test --flake .#gmktec-01  # Test configuration"
          echo "  nixos-rebuild switch --flake .#gmktec-01 # Apply configuration"
          echo "  nix flake update  # Update all inputs"
        '';
      };
    };
}
