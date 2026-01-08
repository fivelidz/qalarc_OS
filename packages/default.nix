{ pkgs }:

{
  claude-code = pkgs.callPackage ./claude-code { };
  opencode = pkgs.callPackage ./opencode { };
  grub-btrfs = pkgs.callPackage ./grub-btrfs { };
}
