{ pkgsUnstable, ... }:

let
  vscode = import ./vscode.nix { inherit pkgsUnstable; };
in
{
  default = final: prev:
    (vscode final prev);
}
