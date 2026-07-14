{ pkgsUnstable, ... }:

{
  default = import ./vscode.nix { inherit pkgsUnstable; };
}
