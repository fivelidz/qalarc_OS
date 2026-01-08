{ config, lib, pkgs, ... }:

with lib;

{
  options.qalarc.portableBoot = {
    enable = mkEnableOption "qalarc_OS portable boot-to-RAM feature";

    copytoram = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable copytoram support in initrd";
      };

      ramSize = mkOption {
        type = types.str;
        default = "75%";
        description = "Size of tmpfs for RAM root (percentage or absolute like '16G')";
      };
    };

    persistence = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable persistence partition support";
      };

      autoMount = mkOption {
        type = types.bool;
        default = true;
        description = "Automatically mount persistence partition at boot";
      };

      autoRestore = mkOption {
        type = types.bool;
        default = false;
        description = "Automatically restore /home from persistence on boot";
      };

      mountPoint = mkOption {
        type = types.str;
        default = "/mnt/qalarc-persist";
        description = "Mount point for persistence partition";
      };
    };

    defaults = {
      includeAIModels = mkOption {
        type = types.bool;
        default = false;
        description = "Include AI models by default when creating portable USB";
      };

      includeUserData = mkOption {
        type = types.bool;
        default = false;
        description = "Include /home by default when creating portable USB";
      };

      compressionLevel = mkOption {
        type = types.int;
        default = 15;
        description = "zstd compression level for squashfs (1-19, higher = smaller but slower)";
      };
    };
  };
}
