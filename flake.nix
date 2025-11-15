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
      mkHost = hostname: nixpkgs.lib.nixosSystem {
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
          ./modules/snapper
          ./modules/networking
          ./modules/development
          ./modules/media
          ./modules/system-monitor

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
        gmktec-01 = mkHost "gmktec-01";
        # Add more hosts as needed
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
