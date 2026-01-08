{ pkgs, lib, config, ... }:

{
  qalarc-create-portable = pkgs.writeShellScriptBin "qalarc-create-portable" (builtins.readFile ./create-portable.sh);
  qalarc-sync-portable = pkgs.writeShellScriptBin "qalarc-sync-portable" (builtins.readFile ./sync-portable.sh);
  qalarc-portable-status = pkgs.writeShellScriptBin "qalarc-portable-status" (builtins.readFile ./portable-status.sh);
  qalarc-portable-gui = pkgs.writeShellScriptBin "qalarc-portable-gui" (builtins.readFile ./portable-gui.sh);
}
