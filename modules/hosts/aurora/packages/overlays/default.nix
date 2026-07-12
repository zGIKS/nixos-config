{ pkgsUnstable, ... }:

let
  discord = import ./discord.nix { inherit pkgsUnstable; };
  vscode = import ./vscode.nix { inherit pkgsUnstable; };
  zed = import ./zed.nix { inherit pkgsUnstable; };
in
{
  default = final: prev:
    (discord final prev) // (vscode final prev) // (zed final prev);
}
