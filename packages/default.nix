{ pkgs }:

{
  # claude-code is now in nixpkgs - use pkgs.claude-code directly
  opencode = pkgs.callPackage ./opencode { };
  grub-btrfs = pkgs.callPackage ./grub-btrfs { };
}
